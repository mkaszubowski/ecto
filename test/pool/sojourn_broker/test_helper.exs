Logger.configure(level: :info)
ExUnit.start

broker =
  case System.get_env("MIX_ENV") do
    "sojourn_timeout" -> EctoOne.Pools.SojournBroker.Timeout
    "sojourn_codel"   -> EctoOne.Pools.SojournBroker.CoDel
  end

Application.put_env(:ecto_one, :pool_opts, pool: EctoOne.Pools.SojournBroker, broker: broker)

# Load support files
Code.require_file "../../support/test_pool.exs", __DIR__