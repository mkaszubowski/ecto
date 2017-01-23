defmodule EctoOne.Adapters.SQLTest do
  use ExUnit.Case, async: true

  defmodule Adapter do
    use EctoOne.Adapters.SQL
    def supports_ddl_transaction?, do: false
  end

  Application.put_env(:ecto_one, __MODULE__.Repo, adapter: Adapter)

  defmodule Repo do
    use EctoOne.Repo, otp_app: :ecto_one
  end

  Application.put_env(:ecto_one, __MODULE__.RepoWithTimeout, adapter: Adapter, pool_timeout: 3000, timeout: 1500)

  defmodule RepoWithTimeout do
    use EctoOne.Repo, otp_app: :ecto_one
  end

  test "stores __pool__ metadata" do
    assert Repo.__pool__ == {EctoOne.Pools.Poolboy, Repo.Pool, 5000, 15000}
    assert RepoWithTimeout.__pool__ ==
      {EctoOne.Pools.Poolboy, RepoWithTimeout.Pool, 3000, 1500}
  end
end
