defmodule Schocken.Game do
  @moduledoc """
  TODO: write some documentation
  """

  alias __MODULE__
  alias Schocken.Game.Player
  alias Schocken.Game.Ranking

  defstruct(
    players: [],
    global_coaster: 13,
    tries: 3,
    current_state: :first_half
  )

  @type t :: %Game{
          players: [Player.t()],
          global_coaster: 0..13,
          tries: 1..3,
          current_state: :first_half | :second_half | :finale
        }

  @doc """
  Returns a new game state
  """
  @spec new(integer) :: t
  def new(number_players) when is_integer(number_players) do
    players =
      Enum.reduce(1..number_players, [], fn id, players ->
        [Player.new("player_" <> to_string(id)) | players]
      end)

    %Game{players: players}
  end

  @doc """
  Making a new move.

  :finish to end the move
  :toss to toss selcted dices
  """
  @spec make_move(t, List | integer | atom) :: t
  def make_move(game, choices)

  # Game is over
  def make_move(
        %Game{players: [_player, %Player{state: :finished} | _rest], current_state: :finale},
        []
      ) do
  end

  # Round is over
  def make_move(%Game{players: [player, %Player{state: :finished} | _] = players} = game, []) do
    player = %Player{player | state: :finished}
    [_ | rest] = players

    %Game{game | players: rest ++ [player]}
    |> calculate_round()
  end

  # Next players turn
  def make_move(%Game{players: [player | rest]} = game, []) do
    player = %Player{player | state: :finished}
    next_player(%Game{game | players: [player] ++ rest})
  end

  # Roll dices
  def make_move(%Game{players: [active_player | rest_players]} = game, choices) do
    %Game{game | players: [Player.roll_dices(active_player, choices) | rest_players]}
  end

  defp calculate_round(%Game{} = game) do
    {best_player, type, number_of_coasters} = Ranking.highest_toss(game.players)
    worst_player = Ranking.lowest_toss(game.players)

    case type do
      :schock_out -> calculate_schock_out_round(game, worst_player)
      _ -> calculate_normal_round(game, best_player, worst_player, number_of_coasters)
    end
  end

  defp calculate_schock_out_round(%Game{players: players} = game, worst_player) do
    game
    |> schock_out_arrange_coasters(worst_player)
    |> update_global_coaster(13)
    |> update_game_state(worst_player)
    |> init_new_round(elem(worst_player, 1))
  end

  defp schock_out_arrange_coasters(%Game{players: players} = game, {lost_player, index}) do
    players
    |> Enum.map(fn player ->
      if player.name == lost_player.name do
        Map.put(player, :num_coaster, 13)
      else
        Map.put(player, :num_coaster, 0)
      end
    end)

    %Game{game | players: players}
  end

  defp calculate_normal_round(
         %Game{global_coaster: global_coaster} = game,
         _best_player,
         worst_player,
         number_of_coasters
       )
       when global_coaster > 0 do
    game
    |> update_players_coaster(worst_player, number_of_coasters)
    |> update_global_coaster(number_of_coasters)
    |> update_players_state()
    |> init_new_round(elem(worst_player, 1))
  end

  defp calculate_normal_round(
         %Game{global_coaster: global_coaster} = game,
         best_player,
         worst_player,
         number_of_coasters
       )
       when global_coaster == 0 do
    game
    |> update_players_coaster(best_player, worst_player, number_of_coasters)
    |> update_players_state()
    |> update_game_state(worst_player)
    |> init_new_round(elem(worst_player, 1))
  end

  defp update_players_coaster(
         game,
         worst_player,
         number_of_coasters
       ) do
    {player, index} = worst_player
    player = Player.update_coaster(player, number_of_coasters)
    players = List.replace_at(game.players, index, player)
    %Game{game | players: players}
  end

  defp update_players_coaster(
         game,
         best_player,
         worst_player,
         number_of_coasters
       ) do
    {worst_player, worst_player_index} = worst_player
    {best_player, best_player_index} = best_player
    worst_player = Player.update_coaster(worst_player, number_of_coasters)
    best_player = Player.update_coaster(best_player, -number_of_coasters)

    players =
      game.players
      |> List.replace_at(worst_player_index, worst_player)
      |> List.replace_at(best_player_index, best_player)

    %Game{game | players: players}
  end

  defp update_global_coaster(%Game{global_coaster: coaster} = game, number)
       when coaster >= number do
    %Game{game | global_coaster: coaster - number}
  end

  defp update_global_coaster(%Game{global_coaster: coaster} = game, number)
       when coaster < number do
    %Game{game | global_coaster: 0}
  end

  # if global_coaster is empty remove all players not having any coaster and make other ready
  defp update_players_state(%Game{players: players, global_coaster: global_coaster} = game)
       when global_coaster == 0 do
    players =
      Enum.map(players, fn player ->
        if player.num_coaster == 0 do
          %Player{player | state: :out}
        else
          %Player{player | state: :ready}
        end
      end)

    %Game{game | players: players}
  end

  # if global_coaster is not empty make players ready again
  defp update_players_state(%Game{players: players, global_coaster: global_coaster} = game)
       when global_coaster > 0 do
    players =
      Enum.map(players, fn player ->
        %Player{player | state: :ready}
      end)

    %Game{game | players: players}
  end

  defp update_game_state(%Game{} = game, worst_player) do
    # only one player left
    if Enum.count(game.players, &(&1.num_coaster == 13)) == 1 do
      if Enum.count(game.players, &(&1.lost_half == true)) == 1 do
        update_game_state(game, worst_player, :finale)
      else
        update_game_state(game, worst_player, :second_half)
      end
    end
  end

  # update game state for finale
  defp update_game_state(%Game{} = game, {_, index}, :finale) do
    players =
      game.players
      |> List.update_at(index, &%Player{&1 | lost_half: true})
      |> Enum.map(fn player ->
        if player.lost_half == true do
          player
          |> Map.put(:state, :ready)
          |> Map.put(:num_coaster, 0)
        end
      end)

    %Game{game | players: players, global_coaster: 13, current_state: :finale}
  end

  # update game state for second_half
  defp update_game_state(%Game{} = game, {_, index}, :second_half) do
    players =
      game.players
      |> List.update_at(index, &%Player{&1 | lost_half: true})
      |> Enum.map(&Map.put(&1, :state, :ready))
      |> Enum.map(&Map.put(&1, :num_coaster, 0))

    %Game{game | players: players, global_coaster: 13, current_state: :second_half}
  end

  defp init_new_round(
         %Game{
           players: players
         } = game,
         lost_player_index
       ) do
    {head, tail} = Enum.split(players, lost_player_index)
    players = (tail ++ head) |> Enum.map(&Player.roll_dices(&1, :all))
    %Game{game | players: players}
  end

  defp next_player(game) do
    %Game{game | players: skip_players(game.players)}
  end

  defp skip_players([%Player{state: :ready} = player | rest]), do: [player] ++ rest

  defp skip_players([player | rest]) do
    skip_players(rest ++ [player])
  end
end
