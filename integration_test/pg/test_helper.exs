Logger.configure(level: :info)
ExUnit.start

# Configure EctoOne for support and tests
Application.put_env(:ecto_one, :lock_for_update, "FOR UPDATE")
Application.put_env(:ecto_one, :primary_key_type, :id)

# Configure PG connection
Application.put_env(:ecto_one, :pg_test_url,
  "ecto_one://" <> (System.get_env("PG_URL") || "postgres:postgres@localhost")
)

# Load support files
Code.require_file "../support/repo.exs", __DIR__
Code.require_file "../support/models.exs", __DIR__
Code.require_file "../support/migration.exs", __DIR__

pool =
  case System.get_env("ECTO_POOL") || "poolboy" do
    "poolboy"        -> EctoOne.Pools.Poolboy
    "sojourn_broker" -> EctoOne.Pools.SojournBroker
  end

# Basic test repo
alias EctoOne.Integration.TestRepo

Application.put_env(:ecto_one, TestRepo,
  adapter: EctoOne.Adapters.Postgres,
  url: Application.get_env(:ecto_one, :pg_test_url) <> "/ecto_one_test",
  pool: EctoOne.Adapters.SQL.Sandbox)

defmodule EctoOne.Integration.TestRepo do
  use EctoOne.Integration.Repo, otp_app: :ecto_one

  def create_prefix(prefix) do
    "create schema #{prefix}"
  end

  def drop_prefix(prefix) do
    "drop schema #{prefix}"
  end
end

# Pool repo for transaction and lock tests
alias EctoOne.Integration.PoolRepo

Application.put_env(:ecto_one, PoolRepo,
  adapter: EctoOne.Adapters.Postgres,
  pool: pool,
  url: Application.get_env(:ecto_one, :pg_test_url) <> "/ecto_one_test",
  pool_size: 10)

defmodule EctoOne.Integration.PoolRepo do
  use EctoOne.Integration.Repo, otp_app: :ecto_one
end

defmodule EctoOne.Integration.Case do
  use ExUnit.CaseTemplate

  setup_all do
    EctoOne.Adapters.SQL.begin_test_transaction(TestRepo, [])
    on_exit fn -> EctoOne.Adapters.SQL.rollback_test_transaction(TestRepo, []) end
    :ok
  end

  setup do
    EctoOne.Adapters.SQL.restart_test_transaction(TestRepo, [])
    :ok
  end
end

# Load up the repository, start it, and run migrations
_   = EctoOne.Storage.down(TestRepo)
:ok = EctoOne.Storage.up(TestRepo)

{:ok, _pid} = TestRepo.start_link
{:ok, _pid} = PoolRepo.start_link

:ok = EctoOne.Migrator.up(TestRepo, 0, EctoOne.Integration.Migration, log: false)
Process.flag(:trap_exit, true)
