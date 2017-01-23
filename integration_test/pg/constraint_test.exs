defmodule EctoOne.Integration.ConstraintTest do
  use ExUnit.Case, async: true

  alias EctoOne.Integration.TestRepo
  import EctoOne.Migrator, only: [up: 4, down: 4]

  defmodule ExcludeConstraintMigration do
    use EctoOne.Migration

    @table table(:exclude_constraint_migration)

    def up do
      create @table do
        add :from, :integer
        add :to, :integer
      end
      execute "ALTER TABLE exclude_constraint_migration ADD CONSTRAINT overlapping_ranges EXCLUDE USING gist (int4range(\"from\", \"to\") WITH &&)"
    end

    def down do
      drop @table
    end
  end

  defmodule ExcludeConstraintModel do
    use EctoOne.Integration.Schema

    schema "exclude_constraint_migration" do
      field :from, :integer
      field :to, :integer
    end
  end

  test "exclude constraint exception" do
    assert :ok == up(TestRepo, 20050906120000, ExcludeConstraintMigration, log: false)

    changeset = EctoOne.Changeset.change(%ExcludeConstraintModel{}, from: 0, to: 1)
    {:ok, _} = TestRepo.insert(changeset)

    exception =
      assert_raise EctoOne.ConstraintError, ~r/constraint error when attempting to insert model/, fn ->
        changeset
        |> TestRepo.insert()
      end

    assert exception.message =~ "exclude: overlapping_ranges"
    assert exception.message =~ "The changeset has not defined any constraint."

    message = ~r/constraint error when attempting to insert model/
    exception =
      assert_raise EctoOne.ConstraintError, message, fn ->
        changeset
        |> EctoOne.Changeset.exclude_constraint(:from)
        |> TestRepo.insert()
      end

    assert exception.message =~ "exclude: overlapping_ranges"

    {:error, changeset} =
      changeset
      |> EctoOne.Changeset.exclude_constraint(:from, name: :overlapping_ranges)
      |> TestRepo.insert()

    assert changeset.errors == [from: "violates an exclusion constraint"]
    assert changeset.model.__meta__.state == :built

    assert :ok == down(TestRepo, 20050906120000, ExcludeConstraintMigration, log: false)
  end
end
