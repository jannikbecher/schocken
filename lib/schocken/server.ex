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
    current_player = List.first(game.players)
    %{
      current_player: %{
        name: current_player.name,
        dices: current_player.current_toss.dices,
        try: current_player.current_toss.tries,
        coasters: current_player.num_coaster
      },
      global_coaster: game.global_coaster,
      allowed_tries: game.global_tries,
      current_state: game.current_state,
      other_players: get_player_status(game),
      valid_moves: get_valid_moves(game)
    }
  end

  defp get_valid_moves(%Game{} = game) do
    # TODO: implement this
    # TODO: fix finale bug!!
  end

  defp get_player_status(%Game{players: players} = game) do
    players
    |> Enum.map(fn player ->
      case player.state do
        :ready ->
          %{name: player.name, status: "ready", coasters: player.num_coaster}
        :finished ->
          %{name: player.name, status: "finished", tries: player.current_toss.tries, dices: player.current_toss.dices_out, coasters: player.num_coaster}
        :out ->
          %{name: player.name, state: "out", coasters: player.num_coaster}
      end
    end)
  end
end
