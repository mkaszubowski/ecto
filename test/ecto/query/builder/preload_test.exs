Code.require_file "../../../support/eval_helpers.exs", __DIR__

defmodule EctoOne.Query.Builder.PreloadTest do
  use ExUnit.Case, async: true

  import EctoOne.Query.Builder.Preload
  doctest EctoOne.Query.Builder.Preload

  import EctoOne.Query
  import Support.EvalHelpers

  test "invalid preload" do
    assert_raise EctoOne.Query.CompileError, ~r"`1` is not a valid preload expression", fn ->
      quote_and_eval(%EctoOne.Query{} |> preload(1))
    end
  end

  test "preload accumulates" do
    query = %EctoOne.Query{} |> preload(:foo) |> preload(:bar)
    assert query.preloads == [:foo, :bar]
  end

  test "preload interpolation" do
    comments = :comments
    assert preload("posts", ^comments).preloads == [:comments]
    assert preload("posts", ^[comments]).preloads == [[:comments]]
    assert preload("posts", [users: ^comments]).preloads == [users: :comments]
    assert preload("posts", [users: ^[comments]]).preloads == [users: [:comments]]
    assert preload("posts", [{^:users, ^comments}]).preloads == [users: :comments]

    query = from u in "users", limit: 10
    assert preload("posts", [users: ^query]).preloads == [users: query]
    assert preload("posts", [{^:users, ^query}]).preloads == [users: query]
    assert preload("posts", [users: ^{query, :comments}]).preloads == [users: {query, :comments}]
  end
end
