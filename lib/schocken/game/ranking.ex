defmodule Schocken.Game.Ranking do
  @moduledoc false

  alias Schocken.Game.Player

  # Hand ranks
  @schock_out 5
  @schock 4
  @general 3
  @straight 2
  @house_number 1

  @doc """
  Evaluates the current toss and returns {rank, high, tries}
  """
  @spec evaluate(Player.current_toss()) :: Player.current_toss()
  def evaluate(current_toss = %{dices: dices, one_toss: one_toss, tries: tries}) do
    score =
      dices
      |> Enum.sort(&(&1 >= &2))
      |> eval(one_toss)
      |> Tuple.append(tries)

    %{current_toss | score: score}
  end

  @spec highest_toss([Player.t()]) :: {{Player.t(), integer}, atom, integer}
  def highest_toss(players) do
    best_player =
      players
      |> Enum.max_by(fn player -> player.current_toss.score end)

    index_best = Enum.find_index(players, fn player -> player.name == best_player.name end)
    {type, number} = calc_amount_of_coasters(best_player)

    {{best_player, index_best}, type, number}
  end

  @spec lowest_toss([Player.t()]) :: {Player.t(), integer}
  def lowest_toss(players) do
    worst_player =
      Enum.min_by(players, fn player ->
        player.current_toss.score
      end)

    index_worst = Enum.find_index(players, fn player -> player.name == worst_player.name end)
    {worst_player, index_worst}
  end

  @spec calc_amount_of_coasters(Player) :: integer
  defp calc_amount_of_coasters(player) do
    score = player.current_toss.score

    case score do
      {5, _, _} -> {:schock_out, 0}
      {4, number, _} -> {:schock, number}
      {3, _, _} -> {:general, 3}
      {2, _, _} -> {:straight, 2}
      _ -> {:house_number, 1}
    end
  end

  @spec eval([Player.dice()], boolean) :: Player.score()
  defp eval(dices, one_toss)

  defp eval([1, 1, 1], _), do: {@schock_out, 0}

  defp eval([h, 1, 1], _), do: {@schock, h}

  defp eval([s, s, s], _), do: {@general, s}

  defp eval([a, b, c], true) when a - c == 2 and a != b and b != c, do: {@straight, a}

  defp eval(dices, _) do
    rank =
      dices
      |> Enum.join()
      |> String.to_integer()

    {@house_number, rank}
  end
end
