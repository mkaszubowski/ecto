defmodule Mix.Tasks.EctoOne.Migrate do
  use Mix.Task
  import Mix.EctoOne

  @shortdoc "Run migrations up on a repo"

  @moduledoc """
  Runs the pending migrations for the given repository.

  By default, migrations are expected at "priv/YOUR_REPO/migrations"
  directo_onery of the current application but it can be configured
  by specify the `:priv` key under the repository configuration.

  Runs all pending migrations by default. To migrate up
  to a version number, supply `--to version_number`.
  To migrate up a specific number of times, use `--step n`.

  If the repository has not been started yet, one will be
  started outside our application supervision tree and shutdown
  afterwards.

  ## Examples

      mix ecto_one.migrate
      mix ecto_one.migrate -r Custom.Repo

      mix ecto_one.migrate -n 3
      mix ecto_one.migrate --step 3

      mix ecto_one.migrate -v 20080906120000
      mix ecto_one.migrate --to 20080906120000

  ## Command line options

    * `-r`, `--repo` - the repo to migrate (defaults to `YourApp.Repo`)
    * `--all` - run all pending migrations
    * `--step` / `-n` - run n number of pending migrations
    * `--to` / `-v` - run all migrations up to and including version
    * `--quiet` - do not log migration commands

  """

  @doc false
  def run(args, migrator \\ &EctoOne.Migrator.run/4) do
    repos = parse_repo(args)

    {opts, _, _} = OptionParser.parse args,
      switches: [all: :boolean, step: :integer, to: :integer, quiet: :boolean],
      aliases: [n: :step, v: :to]

    opts =
      if opts[:to] || opts[:step] || opts[:all] do
        opts
      else
        Keyword.put(opts, :all, true)
      end

    opts =
      if opts[:quiet] do
        Keyword.put(opts, :log, false)
      else
        opts
      end

    Enum.each repos, fn repo ->
      ensure_repo(repo, args)
      {:ok, pid} = ensure_started(repo)

      migrator.(repo, migrations_path(repo), :up, opts)
      pid && ensure_stopped(repo, pid)
    end
  end
end
