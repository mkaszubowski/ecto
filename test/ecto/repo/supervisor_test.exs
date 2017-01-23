defmodule EctoOne.Repo.SupervisorTest do
  use ExUnit.Case, async: true

  import EctoOne.Repo.Supervisor

  defp put_env(env) do
    Application.put_env(:ecto_one, __MODULE__, env)
  end

  test "reads otp app configuration" do
    put_env(database: "hello")
    assert config(__MODULE__, :ecto_one, []) == [otp_app: :ecto_one, repo: __MODULE__, database: "hello"]
  end

  test "merges url into configuration" do
    put_env(database: "hello", url: "ecto_one://eric:hunter2@host:12345/mydb")
    assert Enum.sort(config(__MODULE__, :ecto_one, [extra: "extra"])) ==
           [database: "mydb", extra: "extra", hostname: "host", otp_app: :ecto_one,
            password: "hunter2", port: 12345, repo: __MODULE__, username: "eric"]
  end

  test "merges system url into configuration" do
    System.put_env("ECTO_REPO_CONFIG_URL", "ecto_one://eric:hunter2@host:12345/mydb")
    put_env(database: "hello", url: {:system, "ECTO_REPO_CONFIG_URL"})
    assert Enum.sort(config(__MODULE__, :ecto_one, [])) ==
           [database: "mydb", hostname: "host", otp_app: :ecto_one,
            password: "hunter2", port: 12345, repo: __MODULE__, username: "eric"]
  end

  test "parse_url options" do
    encoded_url = URI.encode("ecto_one://eric:it+й@host:12345/mydb")
    url = parse_url(encoded_url)
    assert {:password, "it+й"} in url
    assert {:username, "eric"} in url
    assert {:hostname, "host"} in url
    assert {:database, "mydb"} in url
    assert {:port, 12345} in url
  end

  test "parse_url from system env" do
    System.put_env("ECTO_REPO_CONFIG_URL", "ecto_one://eric:hunter2@host:12345/mydb")
    url = parse_url({:system, "ECTO_REPO_CONFIG_URL"})
    assert {:password, "hunter2"} in url
    assert {:username, "eric"} in url
    assert {:hostname, "host"} in url
    assert {:database, "mydb"} in url
    assert {:port, 12345} in url
  end

  test "parse_url returns no config when blank" do
    assert parse_url("") == []
    assert parse_url({:system, "ECTO_REPO_CONFIG_NONE_URL"}) == []

    System.put_env("ECTO_REPO_CONFIG_URL", "")
    assert parse_url({:system, "ECTO_REPO_CONFIG_URL"}) == []
  end

  test "parse_urls empty username/password" do
    url = parse_url("ecto_one://host:12345/mydb")
    assert !Dict.has_key?(url, :username)
    assert !Dict.has_key?(url, :password)
  end

  test "fail on invalid urls" do
    assert_raise EctoOne.InvalidURLError, ~r"host is not present", fn ->
      parse_url("eric:hunter2@host:123/mydb")
    end

    assert_raise EctoOne.InvalidURLError, ~r"path should be a database name", fn ->
      parse_url("ecto_one://eric:hunter2@host:123/a/b/c")
    end

    assert_raise EctoOne.InvalidURLError, ~r"path should be a database name", fn ->
      parse_url("ecto_one://eric:hunter2@host:123/")
    end

    assert_raise EctoOne.InvalidURLError, ~r"path should be a database name", fn ->
      parse_url("ecto_one://eric:hunter2@host:123")
    end
  end
end
