defmodule Schocken.Game.Player do
  @moduledoc false

  alias __MODULE__
  alias Schocken.Game.Ranking

  defstruct(
    name: "",
    current_toss: %{dices: nil,
                    dices_out: nil,
                    one_toss: nil,
                    promote: :zero,
                    tries: 0,
                    score: nil
    },
    first_player: false,
    num_coaster: 0,
    state: :ready,
    lost_half: false
  )

  @type t :: %Player{
          name: String.t(),
          current_toss: current_toss,
          first_player: boolean,
          num_coaster: integer,
          state: :ready | :finished | :out,
          lost_half: boolean
        }
  @type dice :: 1..6
  @type tries :: 0..3
  @type score :: {integer, integer, integer}
  @type current_toss :: %{
          dices: [dice],
          dices_out: [dice],
          one_toss: boolean,
          promote: :zero | :one | :two,
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
      |> update_dices_out(choices)
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

  @spec update_dices_out(current_toss, [dice]) :: current_toss
  defp update_dices_out(current_toss, choices) do
    dices = current_toss.dices
    dices_out = cond do
      is_number(choices) -> dices -- [choices]
      is_list(choices) -> dices -- choices
      true -> []
    end
    %{current_toss | dices_out: dices_out}
  end

  @spec do_roll_dices(current_toss, List | :all | 1..6) :: current_toss
  defp do_roll_dices(_current_toss, _choices)

  defp do_roll_dices(current_toss, choice) when is_number(choice) do
    current_toss
    |> reroll_dice(choice)
    |> Map.put(:one_toss, false)
  end

  defp do_roll_dices(current_toss, choices) when length(choices) == 2 do
    six_is_out? = (Enum.count(current_toss.dices, &(&1 == 6)) - Enum.count(choices, &(&1 == 6))) == 1
    Enum.reduce(choices, current_toss, fn choice, toss ->
      reroll_dice(toss, choice)
    end)
    |> Map.put(:one_toss, false)
    |> update_promote(six_is_out?)
  end

  defp do_roll_dices(current_toss, choices) when length(choices) == 3 do
    do_roll_dices(current_toss, :all)
  end

  defp do_roll_dices(current_toss, :all) do
    %{current_toss | dices: [toss(), toss(), toss()], one_toss: true}
    |> update_promote(false) # I know there is a cleaner way, but it works...
  end

  @spec reroll_dice(current_toss, 1..6) :: current_toss
  defp reroll_dice(%{dices: dices} = current_toss, choice) do
    index = Enum.find_index(dices, fn dice -> dice == choice end)
    %{current_toss | dices: List.replace_at(dices, index, toss())}
  end

  @spec update_tries(current_toss) :: current_toss
  defp update_tries(%{tries: tries} = current_toss) do
    %{current_toss | tries: tries + 1}
  end

  @spec update_promote(current_toss, boolean) :: current_toss
  defp update_promote(current_toss, six_is_out?) do
    number_of_sixes = Enum.count(current_toss.dices, &(&1 == 6)) - if six_is_out?, do: 1, else: 0
    case number_of_sixes do
      3 ->
        %{current_toss | promote: :two}
      2 ->
        %{current_toss | promote: :one}
      _ ->
        %{current_toss | promote: :zero}
    end
  end

  @spec toss() :: 1..6
  defp toss(), do: Enum.random(1..6)
end
