defmodule Schocken.Game.Player do
  @moduledoc false

  alias __MODULE__
  alias Schocken.Game.Ranking

  defstruct(
    name: "",
    current_toss: %{dices: nil, one_toss: nil, tries: 0, score: nil}
    num_coaster: 0,
    lost_half: false
  )

  @type t :: %Player{
    name: String.t,
    current_toss: current_toss,
    num_coaster: integer,
    lost_half: boolean
  }
  @type dice :: 1..6
  @type tries :: 0..3
  @type current_toss :: %{
    dices: [dice, dice, dice],
    one_toss: boolean,
    tries: tries,
    score: {integer, integer, integer}
  }

  @doc """
  Returns a new player struct
  """
  def new(name) do
    %Player{
      name: name,
    }
  end

  @doc """
  roll choices
  update tries, one_toss
  call Ranking.evaluate
  return updated player
  """
  @spec roll_dices(Player, List | :all | 1..6) :: Player
  def roll_dices(player = %Player{current_toss: current_toss}, choices) do
    current_toss =
      current_toss
      |> do_roll_dices(choices)
      |> update_tries()
      |> Map.put(one_toss, false)
      |> Ranking.evaluate()
    %Player{player | current_toss: current_toss}
  end

  @spec do_roll_dices(current_toss, List | :all | 1..6)
  defp do_roll_dices(%{}, _choices)

  defp do_roll_dices(current_toss = %{dices: dices}, choice) when is_number(choice) do
    reroll_dice(current_toss)
  end

  defp do_roll_dices(current_toss = %{dices: dices}, :all) do
    {current_toss | dices: [toss(), toss(), toss()]}
  end

  defp do_roll_dices(current_toss = %{dices: dices}, choices) do
    Enum.reduce(choices, current_toss, fn choice, toss ->
      reroll_dice(toss, choice)
    end)
  end

  @spec reroll_dice(current_toss, 1..6) :: current_toss
  defp reroll_dice(current_toss = %{dices: dices}, choice) do
    index = Enum.find_index(dices, fn dice -> dice == choice end)
    %{current_toss | dices: List.replace_at(dices, index, toss())}
  end

  @spec update_tries(current_toss) :: current_toss
  defp update_tries(current_toss = %{tries: tries}) do
    %{current_toss | tries: tries + 1}
  end

  @spec toss() :: 1..6
  defp toss(), do: Enum.random(1..6)
end
