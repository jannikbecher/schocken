defmodule Schocken.Server do
  @moduledoc false

  use GenServer

  alias __MODULE__
  alias Schocken.Game

  def start_link(number_players) do
    GenServer.start_link(Server, number_players)
  end

  def init(number_players) do
    {:ok, Game.new(number_players)}
  end

  def handle_call({:status}, _from, game) do
    {:reply, game, game}
  end
end
