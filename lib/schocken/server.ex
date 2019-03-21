defmodule Schocken.Server do
  @moduledoc false

  use GenServer

  alias __MODULE__
  alias Schocken.Game

  def start_link(%Game{} = game_state) do
    GenServer.start_link(Server, game_state)
  end

  def start_link(number_players) do
    GenServer.start_link(Server, number_players)
  end

  def init(%Game{} = game_state) do
    {:ok, game_state}
  end

  def init(number_players) do
    {:ok, Game.new(number_players)}
  end

  def handle_call({:status}, _from, game) do
    {:reply, status_reply(game), game}
  end

  def handle_call({:make_move, choiches}, _from, game) do
    game = Game.make_move(game, choiches)
    {:reply, status_reply(game), game}
  end

  defp status_reply(game) do
    %{
      current_player: List.first(game.players),
      global_coaster: game.global_coaster,
      tries: game.global_tries,
      current_state: game.current_state,
      other_players: get_already_moved(game)
    }
  end

  defp get_valid_moves(game) do
    IO.puts("hello")
  end

  defp get_already_moved(%Game{players: players} = game) do
    players
    |> Enum.filter(&(&1.state == :finished))
    |> Enum.map(fn player ->
      %{name: player.name, global_tries: player.current_toss.tries, dices: player.current_toss.dices_out}
    end)
  end
end
