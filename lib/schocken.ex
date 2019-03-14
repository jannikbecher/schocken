defmodule Schocken do
  @moduledoc """
  Documentation for Schocken.
  """

  @doc """
  Starting a new supervisor and returning the pid
  """
  def new_game(number_players) do
    {:ok, pid} = DynamicSupervisor.start_child(
      Schocken.DynamicSupervisor,
      {Schocken.Server, number_players}
    )
    pid
  end

  def status(game_pid) do
    GenServer.call(game_pid, {:status})
  end

  def make_move(game_pid, action, params \\ []) do
    GenServer.call(game_pid, {:make_move, action, params})
  end
end
