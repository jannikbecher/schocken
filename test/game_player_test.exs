defmodule Schocken.Game.PlayerTest do
  use ExUnit.Case

  alias Schocken.Game.Player

  setup do
    player = Player.new("Jannik")
    {:ok, player: player}
  end

  test "create new player", context do
    player = context.player
    result = %Player{
      name: "Jannik",
      current_toss: nil,
      num_coaster: 0,
      lost_half: false
    }
    assert player == Map.put(result, :current_toss, player.current_toss)
  end

  test "roll one dice", context do
    player = context.player
    choice = List.first(player.current_toss.dices)
    new_player = Player.roll_dices(player, choice)
    assert player != new_player
    assert new_player.current_toss.tries == 2
  end

  test "roll all dices", context do
    player = context.player
    new_player = Player.roll_dices(player, :all)
    assert player != new_player
  end

  test "roll two dices", context do
    player = context.player
    dices = player.current_toss.dices
    choices = [List.first(dices), List.last(dices)]
    new_player = Player.roll_dices(player, choices)
    assert player != new_player
  end
end
