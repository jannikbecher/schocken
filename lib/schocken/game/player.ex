defmodule Schocken.Game.Player do
  @moduledoc false

  alias __MODULE__

  defstruct(
    name: "",
    dices: {},
    num_coaster: 0,
    lost_half: false
  )

  @type t :: %Player{
    name: String.t,
    dices: {dice, dice, dice},
    num_coaster: integer,
    lost_half: boolean
  }
  @type dice :: 1..6

  @doc """
  Returns a new player struct
  """
  def create_new_player(name) do
    %Player{
      name: name,
    }
  end
end
