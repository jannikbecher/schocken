defmodule Schocken.GameTest do
  use ExUnit.Case

  alias Schocken.Game

  test "create new game" do
    game = Game.new(3)
  end
end
