defmodule Schocken.GameTest do
  use ExUnit.Case

  alias Schocken.Game
  alias Schocken.Game.Player

  test "test game", context do
    %Game{
      players: [
        %Player{
          name: "player_1",
          current_toss: %{dices: [1, 2, 3], dices_out: [], one_toss: true, promote: :zero, tries: 1, score: {2, 3, 1}},
          num_coaster: 0,
          state: :ready,
          lost_half: false
        },
        %Player{
          name: "player_2",
          current_toss: %{dices: [2, 2, 3], dices_out: [], one_toss: true, promote: :zero, tries: 1, score: {1, 322, 1}},
          num_coaster: 0,
          state: :ready,
          lost_half: false
        }
      ],
      global_coaster: 13,
      global_tries: 0,
      current_state: :first_half
    }
    |> Game.make_move([])
    |> Game.make_move([])
  end

  test "lost first half" do
    game =
    %Game{
      players: [
        %Player{
          name: "player_1",
          current_toss: %{dices: [1, 2, 3], dices_out: [], one_toss: true, promote: :zero, tries: 1, score: {2, 3, 1}},
          num_coaster: 2,
          state: :ready,
          lost_half: false
        },
        %Player{
          name: "player_2",
          current_toss: %{dices: [2, 2, 3], dices_out: [], one_toss: true, promote: :zero, tries: 1, score: {1, 322, 1}},
          num_coaster: 11,
          state: :ready,
          lost_half: false
        }
      ],
      global_coaster: 0,
      global_tries: 0,
      current_state: :first_half
    }
    |> Game.make_move([])
    |> Game.make_move([])
    assert List.first(game.players).lost_half == true
    assert game.current_state == :second_half
  end

  test "lost second half" do
    game =
      %Game{
        players: [
          %Player{
            name: "player_1",
            current_toss: %{dices: [1, 2, 3], dices_out: [], one_toss: true, promote: :zero, tries: 1, score: {2, 3, 1}},
            num_coaster: 2,
            state: :ready,
            lost_half: true
          },
          %Player{
            name: "player_2",
            current_toss: %{dices: [2, 2, 3], dices_out: [], one_toss: true, promote: :zero, tries: 1, score: {1, 322, 1}},
            num_coaster: 11,
            state: :ready,
            lost_half: false
          }
        ],
        global_coaster: 0,
        global_tries: 0,
        current_state: :second_half
      }
      |> Game.make_move([])
      |> Game.make_move([])
    assert List.first(game.players).lost_half == true
    assert game.current_state == :finale
  end

  test "global_tries" do
    game =
      %Game{
        players: [
          %Player{
            name: "player_1",
            current_toss: %{dices: [1, 2, 3], dices_out: [], one_toss: true, promote: :zero, tries: 2, score: {2, 3, 1}},
            first_player: true,
            num_coaster: 2,
            state: :ready,
            lost_half: true
          },
          %Player{
            name: "player_2",
            current_toss: %{dices: [2, 2, 3], dices_out: [], one_toss: true, promote: :zero, tries: 1, score: {1, 322, 1}},
            first_player: false,
            num_coaster: 3,
            state: :ready,
            lost_half: true
          }
        ],
        global_coaster: 8,
        global_tries: 0,
        current_state: :finale
      }
      |> Game.make_move([])
    assert game.global_tries == 2
    game = Game.make_move(game, [])
    assert List.first(game.players).first_player == true
  end

  test "shockout" do
    game =
      %Game{
        players: [
          %Player{
            name: "player_1",
            current_toss: %{dices: [1, 1, 1], dices_out: [], one_toss: true, promote: :zero, tries: 1, score: {5, 0, 1}},
            num_coaster: 2,
            state: :ready,
            lost_half: true
          },
          %Player{
            name: "player_2",
            current_toss: %{dices: [2, 2, 3], dices_out: [], one_toss: true, promote: :zero, tries: 1, score: {1, 322, 1}},
            num_coaster: 6,
            state: :ready,
            lost_half: false
          }
        ],
        global_coaster: 5,
        global_tries: 0,
        current_state: :second_half
      }
      |> Game.make_move([])
      |> Game.make_move([])
    assert game.current_state == :finale
    assert List.first(game.players).num_coaster == 0
    assert List.first(game.players).state == :ready
  end

  test "more than two players, kicking player out" do
    game =
      %Game{
        current_state: :second_half,
        global_coaster: 0,
        players: [
          %Player{
            current_toss: %{
              dices: [1, 6, 6],
              dices_out: [],
              one_toss: true,
              promote: :one,
              score: {1, 661, 1},
              tries: 1
            },
            lost_half: false,
            name: "player_2",
            num_coaster: 10,
            state: :ready
          },
          %Player{
            current_toss: %{
              dices: [5, 1, 6],
              dices_out: [],
              one_toss: true,
              promote: :zero,
              score: {1, 651, 1},
              tries: 1
            },
            lost_half: false,
            name: "player_3",
            num_coaster: 0,
            state: :out
          },
          %Player{
            current_toss: %{
              dices: [4, 2, 3],
              dices_out: [],
              one_toss: true,
              promote: :zero,
              score: {2, 4, 1},
              tries: 1
            },
            lost_half: false,
            name: "player_1",
            num_coaster: 3,
            state: :ready
          }
        ],
        global_tries: 3
      }
      |> Game.make_move([])
      |> Game.make_move([])
    assert List.first(game.players).num_coaster == 12
  end

  test "ending game" do
    game =
      %Game{
        current_state: :finale,
        global_coaster: 0,
        players: [
          %Player{
            current_toss: %{
              dices: [1, 6, 6],
              dices_out: [],
              one_toss: true,
              promote: :one,
              score: {1, 661, 1},
              tries: 1
            },
            lost_half: true,
            name: "player_2",
            num_coaster: 10,
            state: :ready
          },
          %Player{
            current_toss: %{
              dices: [5, 1, 6],
              dices_out: [],
              one_toss: true,
              promote: :zero,
              score: {1, 651, 1},
              tries: 1
            },
            lost_half: false,
            name: "player_3",
            num_coaster: 0,
            state: :out
          },
          %Player{
            current_toss: %{
              dices: [1, 1, 3],
              dices_out: [],
              one_toss: true,
              promote: :zero,
              score: {4, 3, 1},
              tries: 1
            },
            lost_half: true,
            name: "player_1",
            num_coaster: 3,
            state: :ready
          }
        ],
        global_tries: 3
      }
      |> Game.make_move([])
      |> Game.make_move([])
      |> Game.make_move([])
      |> Game.make_move([])
    assert game.current_state == :over
  end
end
