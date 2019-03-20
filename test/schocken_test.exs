defmodule SchockenTest do
  use ExUnit.Case
  doctest Schocken

  setup do
    game =
      %{
        players: [
          %{
            name: "player_1",
            current_toss: %{dices: [1, 2, 3], one_toss: true, promote: :zero, tries: 1, score: {2, 3, 1}},
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

  test "resume already started game", context do
    game = context.game
    Schocken.make_move(game, [])
    status = Schocken.status(game)
    assert status.current_player.name == "player_2"
  end

  test "normal game", context do
    game = Schocken.new_game(3)
    Schocken.make_move(game, :all)
    Schocken.make_move(game, [])
    Schocken.make_move(game, [])
  end
end
