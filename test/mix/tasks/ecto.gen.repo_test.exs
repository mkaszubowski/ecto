defmodule Mix.Tasks.EctoOne.Gen.RepoTest do
  use ExUnit.Case

  import Support.FileHelpers
  import Mix.Tasks.EctoOne.Gen.Repo, only: [run: 1]

  test "generates a new repo" do
    in_tmp fn _ ->
      run ["-r", "Repo"]

      assert_file "lib/repo.ex", """
      defmodule Repo do
        use EctoOne.Repo, otp_app: :ecto_one
      end
      """

      assert_file "config/config.exs", """
      use Mix.Config

      config :ecto_one, Repo,
        adapter: EctoOne.Adapters.Postgres,
        database: "ecto_one_repo",
        username: "user",
        password: "pass",
        hostname: "localhost"
      """
    end
  end

  test "generates a new repo with existing config file" do
    in_tmp fn _ ->
      File.mkdir_p! "config"
      File.write! "config/config.exs", """
      # Hello
      use Mix.Config
      # World
      """

      run ["-r", "Repo"]

      assert_file "config/config.exs", """
      # Hello
      use Mix.Config

      config :ecto_one, Repo,
        adapter: EctoOne.Adapters.Postgres,
        database: "ecto_one_repo",
        username: "user",
        password: "pass",
        hostname: "localhost"

      # World
      """
    end
  end


  test "generates a new namespaced repo" do
    in_tmp fn _ ->
      run ["-r", "My.AppRepo"]
      assert_file "lib/my/app_repo.ex", "defmodule My.AppRepo do"
    end
  end

  test "generates default repo" do
    in_tmp fn _ ->
      run []
      assert_file "lib/ecto_one/repo.ex", "defmodule EctoOne.Repo do"
    end
  end
end
