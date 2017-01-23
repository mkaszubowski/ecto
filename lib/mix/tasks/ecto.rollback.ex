defmodule Mix.Tasks.EctoOne.Rollback do
  use Mix.Task
  import Mix.EctoOne

  @shortdoc "Rollback migrations from a repo"

  @moduledoc """
  Reverts applied migrations in the given repository.

  By default, migrations are expected at "priv/YOUR_REPO/migrations"
  directo_onery of the current application but it can be configured
  by specify the `:priv` key under the repository configuration.

  Runs the latest applied migration by default. To roll back to
  to a version number, supply `--to version_number`.
  To roll back a specific number of times, use `--step n`.
  To undo all applied migrations, provide `--all`.

  If the repository has not been started yet, one will be
  started outside our application supervision tree and shutdown
  afterwards.

  ## Examples

      mix ecto_one.rollback
      mix ecto_one.rollback -r Custom.Repo

      mix ecto_one.rollback -n 3
      mix ecto_one.rollback --step 3

      mix ecto_one.rollback -v 20080906120000
      mix ecto_one.rollback --to 20080906120000

  ## Command line options

    * `-r`, `--repo` - the repo to rollback (defaults to `YourApp.Repo`)
    * `--all` - revert all applied migrations
    * `--step` / `-n` - rever n number of applied migrations
    * `--to` / `-v` - revert all migrations down to and including version
    * `--quiet` - do not log migration commands

  """

  @doc false
  def run(args, migrator \\ &EctoOne.Migrator.run/4) do
    repos = parse_repo(args)

    {opts, _, _} = OptionParser.parse args,
      switches: [all: :boolean, step: :integer, to: :integer, start: :boolean, quiet: :boolean],
      aliases: [n: :step, v: :to]

    opts =
      if opts[:to] || opts[:step] || opts[:all] do
        opts
      else
        Keyword.put(opts, :step, 1)
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

      migrator.(repo, migrations_path(repo), :down, opts)
      pid && ensure_stopped(repo, pid)
    end
  end
end
