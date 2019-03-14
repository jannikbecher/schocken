defmodule Schocken do
  @moduledoc """
  Documentation for Schocken.
  """

  @doc """
  Starting a new supervisor and returning the pid
  """
  def new_game do
    {:ok, pid} = Supervisor.start_child(Schocken.Supervisor, [])
    pid
  end
end
