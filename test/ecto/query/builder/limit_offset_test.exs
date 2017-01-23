defmodule EctoOne.Query.Builder.LimitOffsetTest do
  use ExUnit.Case, async: true

  import EctoOne.Query

  test "overrides on duplicated limit and offset" do
    %EctoOne.Query{limit: %EctoOne.Query.QueryExpr{expr: limit}} = %EctoOne.Query{} |> limit([], 1) |> limit([], 2)
    assert limit == 2

    %EctoOne.Query{offset: %EctoOne.Query.QueryExpr{expr: offset}} = %EctoOne.Query{} |> offset([], 1) |> offset([], 2) |> select([], 3)
    assert offset == 2
  end
end
