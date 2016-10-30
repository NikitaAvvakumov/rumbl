defmodule InfoSys.Backends.WolframTest do
  use ExUnit.Case, async: true
  alias InfoSys.Wolfram

  test "makes request, reports results & terminates" do
    result_text = "...that is the question.\n(according to Prince Hamlet in William Shakespeare"
    ref = make_ref()

    {:ok, pid} = Wolfram.start_link("to be?", ref, self(), 1)
    Process.monitor(pid)

    assert_receive {:results, ^ref, [%InfoSys.Result{text: ^result_text}]}
    assert_receive {:DOWN, _ref, :process, ^pid, :normal}
  end

  test "empty query results reported as empty list" do
    ref = make_ref

    {:ok, _} = Wolfram.start_link("none", ref, self(), 1)

    assert_receive {:results, ^ref, []}
  end
end
