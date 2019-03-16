defmodule Schocken.GameTest do
  use ExUnit.Case

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

  test "test game", context do
    
  end

  alias Schocken.Game
end
