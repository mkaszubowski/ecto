Code.require_file "../../../support/eval_helpers.exs", __DIR__

defmodule EctoOne.Query.Builder.LockTest do
  use ExUnit.Case, async: true

  import EctoOne.Query.Builder.Lock
  doctest EctoOne.Query.Builder.Lock

  import EctoOne.Query
  import Support.EvalHelpers

  test "invalid lock" do
    assert_raise EctoOne.Query.CompileError, ~r"`1` is not a valid lock", fn ->
      quote_and_eval(%EctoOne.Query{} |> lock(1))
    end
  end

  test "overrides on duplicated lock" do
    query = %EctoOne.Query{} |> lock("FOO") |> lock("BAR")
    assert query.lock == "BAR"
  end
end
