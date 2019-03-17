defmodule Schocken.Game.Player do
  @moduledoc false

  alias __MODULE__
  alias Schocken.Game.Ranking

  defstruct(
    name: "",
    current_toss: %{dices: nil, one_toss: nil, tries: 0, score: nil},
    num_coaster: 0,
    state: :ready,
    lost_half: false
  )

  @type t :: %Player{
          name: String.t(),
          current_toss: current_toss,
          num_coaster: integer,
          state: :ready | :finished | :out,
          lost_half: boolean
        }
  @type dice :: 1..6
  @type tries :: 0..3
  @type score :: {integer, integer, integer}
  @type current_toss :: %{
          dices: [dice],
          one_toss: boolean,
          tries: tries,
          score: score
        }

  @doc """
  Returns a new player struct
  """
  def new(name) do
    %Player{name: name}
    |> roll_dices(:all)
  end

  @doc """
  roll choices
  update tries, one_toss
  call Ranking.evaluate
  return updated player
  """
  @spec roll_dices(Player, List | :all | 1..6) :: Player
  def roll_dices(%Player{current_toss: current_toss} = player, choices) do
    current_toss =
      current_toss
      |> do_roll_dices(choices)
      |> update_tries()
      |> Ranking.evaluate()

    %Player{player | current_toss: current_toss}
  end

  @doc """
  update the coaster of the player. +for add -for substract
  """
  @spec update_coaster(t, integer) :: {:ok | :out, t}
  def update_coaster(%Player{num_coaster: num_coaster} = player, number) do
    new_value = num_coaster + number

    cond do
      new_value > 0 ->
        %Player{player | num_coaster: new_value}

      true ->
        %Player{player | num_coaster: 0}
    end
  end

  @spec do_roll_dices(current_toss, List | :all | 1..6) :: current_toss
  defp do_roll_dices(_current_toss, _choices)

  defp do_roll_dices(current_toss, choice) when is_number(choice) do
    current_toss
    |> reroll_dice(choice)
    |> Map.put(:one_toss, false)
  end

  defp do_roll_dices(current_toss, choices) when length(choices) < 3 do
    Enum.reduce(choices, current_toss, fn choice, toss ->
      reroll_dice(toss, choice)
    end)
    |> Map.put(:one_toss, false)
  end

  defp do_roll_dices(current_toss, choices) when length(choices) == 3 do
    do_roll_dices(current_toss, :all)
  end

  defp do_roll_dices(current_toss, :all) do
    %{current_toss | dices: [toss(), toss(), toss()], one_toss: true}
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
