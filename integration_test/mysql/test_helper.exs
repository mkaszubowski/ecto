Logger.configure(level: :info)

# :uses_usec, :uses_msec and :modify_column are supported
# on MySQL 5.6 but that is not yet supported in travis.
ExUnit.start exclude: [:array_type, :read_after_writes, :uses_usec, :uses_msec,
                       :strict_savepoint, :create_index_if_not_exists, :modify_column]

# Configure EctoOne for support and tests
Application.put_env(:ecto_one, :lock_for_update, "FOR UPDATE")
Application.put_env(:ecto_one, :primary_key_type, :id)

# Configure MySQL connection
Application.put_env(:ecto_one, :mysql_test_url,
  "ecto_one://" <> (System.get_env("MYSQL_URL") || "root@localhost")
)

# Load support files
Code.require_file "../support/repo.exs", __DIR__
Code.require_file "../support/models.exs", __DIR__
Code.require_file "../support/migration.exs", __DIR__
Code.require_file "./support/migration.exs", __DIR__

pool =
  case System.get_env("ECTO_POOL") || "poolboy" do
    "poolboy"        -> EctoOne.Pools.Poolboy
    "sojourn_broker" -> EctoOne.Pools.SojournBroker
  end

# Basic test repo
alias EctoOne.Integration.TestRepo

Application.put_env(:ecto_one, TestRepo,
  adapter: EctoOne.Adapters.MySQL,
  url: Application.get_env(:ecto_one, :mysql_test_url) <> "/ecto_one_test",
  pool: EctoOne.Adapters.SQL.Sandbox)

defmodule EctoOne.Integration.TestRepo do
  use EctoOne.Integration.Repo, otp_app: :ecto_one

  def create_prefix(prefix) do
    "create database #{prefix}"
  end

  def drop_prefix(prefix) do
    "drop database #{prefix}"
  end
end

# Pool repo for transaction and lock tests
alias EctoOne.Integration.PoolRepo

Application.put_env(:ecto_one, PoolRepo,
  adapter: EctoOne.Adapters.MySQL,
  pool: pool,
  url: Application.get_env(:ecto_one, :mysql_test_url) <> "/ecto_one_test",
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
:ok = EctoOne.Migrator.up(TestRepo, 1, EctoOne.Integration.MySQL.Migration, log: false)
Process.flag(:trap_exit, true)
