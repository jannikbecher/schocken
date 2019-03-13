defmodule SchockenTest do
  use ExUnit.Case
  doctest Schocken

  test "greets the world" do
    assert Schocken.hello() == :world
  end
end
