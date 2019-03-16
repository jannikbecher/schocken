defmodule Schocken.Game.RankingTest do
  use ExUnit.Case

  alias Schocken.Game.Ranking

  setup do
    toss = %{
      one_toss: true,
      score: nil,
      tries: 1
    }

    {:ok, toss: toss}
  end

  test "ranking of house number", context do
    assert {1, 331, 1} == get_eval([1, 3, 3], context.toss)
  end

  test "ranking of street", context do
    assert {2, 3, 1} == get_eval([1, 2, 3], context.toss)
  end

  test "ranking not one toss street", context do
    toss = Map.put(context.toss, :one_toss, false)
    assert {1, 321, 1} == get_eval([1, 2, 3], toss)
  end

  test "ranking of general", context do
    assert {3, 5, 1} == get_eval([5, 5, 5], context.toss)
  end

  test "ranking of shock", context do
    assert {4, 4, 1} == get_eval([1, 4, 1], context.toss)
  end

  test "ranking of shockout", context do
    assert {5, 0, 1} == get_eval([1, 1, 1], context.toss)
  end

  defp get_eval(dices, toss) do
    Map.put(toss, :dices, dices)
    |> Ranking.evaluate()
    |> Map.get(:score)
  end
end
