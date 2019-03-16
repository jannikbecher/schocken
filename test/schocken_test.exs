defmodule SchockenTest do
  use ExUnit.Case
  doctest Schocken

  setup do
    game = 
    %{
      players: [
        %{
          name: "player_1",
          current_toss: %{dices: [1, 2, 3], one_toss: true, tries: 1, score: {2, 3, 1}},
          num_coaster: 0,
          state: :ready,
          lost_half: false
        },
        %{
          name: "player_2",
          current_toss: %{dices: [2, 2, 3], one_toss: true, tries: 1, score: {1, 322, 1}},
          num_coaster: 0,
          state: :ready,
          lost_half: false
        }
      ],
      global_coaster: 13,
      tries: 0,
      current_state: :first_half
    }
    |> Schocken.new_game()
    {:ok, game: game}
  end

  test "finish move", context do
    game = context.game
    Schocken.make_move(game, [])
    status = Schocken.status(game)
    assert status.current_player.name == "player_2"
  end

  test "dice all", context do
    game = context.game
    |> Schocken.make_move(2)
    |> Schocken.make_move([1, 3])
    |> Schocken.make_move([])
    |> Schocken.make_move([2, 2])
    |> Schocken.make_move(3)
    |> Schocken.make_move([])
  end
end
