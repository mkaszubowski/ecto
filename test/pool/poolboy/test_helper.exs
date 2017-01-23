Logger.configure(level: :info)
ExUnit.start

# Load support files
Application.put_env(:ecto_one, :pool_opts, pool: EctoOne.Pools.Poolboy)
Code.require_file "../../support/test_pool.exs", __DIR__
