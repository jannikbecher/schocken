defmodule Schocken do
  @moduledoc """
  Documentation for Schocken.
  """

  @doc """
  Starting a new supervisor and returning the pid
  """
  def new_game(number_players) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        Schocken.DynamicSupervisor,
        {Schocken.Server, number_players}
      )

    pid
  end

  def status(game_pid) do
    GenServer.call(game_pid, {:status})
  end

  @doc """
  Making a valid move

  ## Parameters
    - game_pid: PID of the game
    - choices: List of dices you want to toss.
               Empty list for ending your turn
  """
  def make_move(game_pid, choices) do
    GenServer.call(game_pid, {:make_move, choices})
  end
end
