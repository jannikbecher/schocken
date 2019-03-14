defmodule Schocken.Game.Ranking do
  @moduledoc false

  alias Schocken.Game.Player

  # Hand ranks
  @schock_out   5
  @schock       4
  @general      3
  @straight     2
  @house_number 1

  @doc """
  Evaluates the current toss and returns {rank, high, tries}
  """
  @spec evaluate(Player.current_toss) :: Player.current_toss
  def evaluate(current_toss = %{dices: dices, one_toss: one_toss, tries: tries}) do
    dices |> Enum.sort(&(&1 >= &2)) |> eval(one_toss)
    |> Tuple.append(tries)
  end

  defp eval([1, 1, 1], _), do: {@schock_out, 0}

  defp eval([h, 1, 1], _), do: {@schock, h}

  defp eval([s, s, s], _), do: {@general, s}

  defp eval([a, b, c], true) when a - c == 2, do: {@straight, s}

  defp eval(dices, _) do
    rank =
      dices
      |> Enum.join()
      |> String.to_integer()
    {@house_number, rank}
  end
end
