defmodule EctoOne.Query.Builder.DistinctTest do
  use ExUnit.Case, async: true

  import EctoOne.Query.Builder.Distinct
  doctest EctoOne.Query.Builder.Distinct

  test "escape" do
    assert {Macro.escape(quote do [&0.y] end), %{}} ==
           escape(quote do x.y end, [x: 0], __ENV__)

    assert {Macro.escape(quote do [&0.x, &1.y] end), %{}} ==
           escape(quote do [x.x, y.y] end, [x: 0, y: 1], __ENV__)

    import Kernel, except: [>: 2]
    assert {Macro.escape(quote do [1 > 2] end), %{}} ==
           escape(quote do 1 > 2 end, [], __ENV__)
  end

  test "escape raise" do
    assert_raise EctoOne.Query.CompileError, "unbound variable `x` in query", fn ->
      escape(quote do x.y end, [], __ENV__)
    end
  end
end
