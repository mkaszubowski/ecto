defmodule EctoOne.Integration.SQLTest do
  use ExUnit.Case, async: true

  alias EctoOne.Integration.PoolRepo, as: Repo
  alias EctoOne.Integration.Barebone
  import EctoOne.Query, only: [from: 2]

  test "query!/4" do
    result = EctoOne.Adapters.SQL.query!(Repo, "SELECT 1", [])
    assert result.rows == [[1]]
  end

  test "to_sql/3" do
    {sql, []} = EctoOne.Adapters.SQL.to_sql(:all, Repo, Barebone)
    assert sql =~ "SELECT"
    assert sql =~ "barebones"

    {sql, [0]} = EctoOne.Adapters.SQL.to_sql(:update_all, Repo,
                                          from(b in Barebone, update: [set: [num: ^0]]))
    assert sql =~ "UPDATE"
    assert sql =~ "barebones"
    assert sql =~ "SET"

    {sql, []} = EctoOne.Adapters.SQL.to_sql(:delete_all, Repo, Barebone)
    assert sql =~ "DELETE"
    assert sql =~ "barebones"
  end
end
