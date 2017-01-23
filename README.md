# EctoOne

[![Build Status](https://travis-ci.org/elixir-lang/ecto_one.svg?branch=master)](https://travis-ci.org/elixir-lang/ecto_one)
[![Inline docs](http://inch-ci.org/github/elixir-lang/ecto_one.svg?branch=master&style=flat)](http://inch-ci.org/github/elixir-lang/ecto_one)

EctoOne is a domain specific language for writing queries and interacting with databases in Elixir. Here is an example:

```elixir
# In your config/config.exs file
config :my_app, Sample.Repo,
  adapter: EctoOne.Adapters.Postgres,
  database: "ecto_one_simple",
  username: "postgres",
  password: "postgres"

# In your application code
defmodule Sample.Repo do
  use EctoOne.Repo,
    otp_app: :my_app
end

defmodule Sample.Weather do
  use EctoOne.Schema

  schema "weather" do
    field :city     # Defaults to type :string
    field :temp_lo, :integer
    field :temp_hi, :integer
    field :prcp,    :float, default: 0.0
  end
end

defmodule Sample.App do
  import EctoOne.Query
  alias Sample.Weather
  alias Sample.Repo

  def keyword_query do
    query = from w in Weather,
          where: w.prcp > 0 or is_nil(w.prcp),
         select: w
    Repo.all(query)
  end

  def pipe_query do
    Weather
    |> where(city: "Kraków")
    |> order_by(:temp_lo)
    |> limit(10)
    |> Repo.all
  end
end
```

See the [online documentation](http://hexdocs.pm/ecto_one) or [run the sample application](https://github.com/elixir-lang/ecto_one/tree/master/examples/simple) for more information.

## Usage

You need to add both EctoOne and the database adapter as a dependency to your `mix.exs` file. The supported databases and their adapters are:

Database                | EctoOne Adapter           | Dependency
:---------------------- | :--------------------- | :-------------------
PostgreSQL              | EctoOne.Adapters.Postgres | [postgrex][postgrex]
MySQL                   | EctoOne.Adapters.MySQL    | [mariaex][mariaex]
MSSQL                   | Tds.EctoOne               | [tds_ecto_one][tds_ecto_one]
SQLite3                 | Sqlite.EctoOne            | [sqlite_ecto_one][sqlite_ecto_one]
MongoDB                 | Mongo.EctoOne             | [mongodb_ecto_one][mongodb_ecto_one]

[postgrex]: http://github.com/ericmj/postgrex
[mariaex]: http://github.com/xerions/mariaex
[tds_ecto_one]: https://github.com/livehelpnow/tds_ecto_one
[sqlite_ecto_one]: https://github.com/jazzyb/sqlite_ecto_one
[mongodb_ecto_one]: https://github.com/michalmuskala/mongodb_ecto_one

For example, if you want to use PostgreSQL, add to your `mix.exs` file:

```elixir
defp deps do
  [{:postgrex, ">= 0.0.0"},
   {:ecto_one, "~> 1.0"}]
end
```

and update your applications list to include both projects:

```elixir
def application do
  [applications: [:postgrex, :ecto_one]]
end
```

Then run `mix deps.get` in your shell to fetch the dependencies. If you want to use another database, just choose the proper dependency from the table above.

Finally, in the repository configuration, you will need to specify the `adapter:` respective to the chosen dependency. For PostgreSQL it is:

```elixir
config :my_app, Repo,
  adapter: EctoOne.Adapters.Postgres,
  ...
```

We are currently looking for contributions to add support for other SQL databases and folks interested in exploring non-relational databases too.

## Important links

  * [Documentation](http://hexdocs.pm/ecto_one)
  * [Mailing list](https://groups.google.com/forum/#!forum/elixir-ecto_one)
  * [Examples](https://github.com/elixir-lang/ecto_one/tree/master/examples)

## Contributing

For overall guidelines, please see [CONTRIBUTING.md](CONTRIBUTING.md).

### Running tests

Clone the repo and fetch its dependencies:

```
$ git clone https://github.com/elixir-lang/ecto_one.git
$ cd ecto_one
$ mix deps.get
$ mix test
```

Besides the unit tests above, it is recommended to run the adapter integration tests too:

```
# Run only PostgreSQL tests (version of PostgreSQL must be >= 9.4 to support jsonb)
MIX_ENV=pg mix test

# Run all tests (unit and all adapters/pools)
mix test.all
```

### Building docs

```
$ MIX_ENV=docs mix docs
```

## Copyright and License

Copyright (c) 2012, Plataformatec.

EctoOne source code is licensed under the [Apache 2 License](LICENSE.md).
