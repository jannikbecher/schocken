defmodule SchockenTest do
  use ExUnit.Case
  doctest Schocken

  setup do
    game = Schocken.new_game(6)
    {:ok, game: game}
  end

  test "finish move", context do
    game = context.game
    Schocken.make_move(game, [])
    status = Schocken.status(game)
    assert status.current_player.name == "player_5"
  end

  test "dice all", context do
    game = context.game
    status = Schocken.status(game)
    |> IO.inspect(label: "before")
    Schocken.make_move(game, :all)
    |> IO.inspect(label: "after")
    status = Schocken.status(game)
  end
end
