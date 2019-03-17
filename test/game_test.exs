defmodule Schocken.GameTest do
  use ExUnit.Case

  alias Schocken.Game
  alias Schocken.Game.Player

  test "test game", context do
    %Game{
      players: [
        %Player{
          name: "player_1",
          current_toss: %{dices: [1, 2, 3], one_toss: true, tries: 1, score: {2, 3, 1}},
          num_coaster: 0,
          state: :ready,
          lost_half: false
        },
        %Player{
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
    |> Game.make_move([])
    |> Game.make_move([])
  end

  test "test2" do
    %Game{
      players: [
        %Player{
          name: "player_1",
          current_toss: %{dices: [1, 2, 3], one_toss: true, tries: 1, score: {2, 3, 1}},
          num_coaster: 2,
          state: :ready,
          lost_half: false
        },
        %Player{
          name: "player_2",
          current_toss: %{dices: [2, 2, 3], one_toss: true, tries: 1, score: {1, 322, 1}},
          num_coaster: 11,
          state: :ready,
          lost_half: false
        }
      ],
      global_coaster: 0,
      tries: 0,
      current_state: :first_half
    }
    |> Game.make_move([])
  end

  alias Schocken.Game
end
