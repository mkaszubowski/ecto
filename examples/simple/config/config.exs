use Mix.Config

config :simple, Simple.Repo,
  adapter: EctoOne.Adapters.Postgres,
  database: "ecto_one_simple",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
