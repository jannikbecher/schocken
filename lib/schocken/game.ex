defmodule Schocken.Game do
  @moduledoc """
  TODO: write some documentation
  """

  alias __MODULE__
  alias Schocken.Game.Player

  defstruct(
    active_players: [],
    waiting_players: [],
    out_players: [],
    global_coaster: 13,
    tries: 3,
    current_state: %{round: :first, phase: :pre}
  )

  @type t :: %Game{
    active_players: [Player],
    waiting_players: [Player],
    out_players: [Player],
    global_coaster: 0..13,
    tries: 1..3,
    current_state: %{round: :first | :second | :finale, phase: :pre | :post}
  }

  @doc """
  Returns a new game state
  """
  @spec new(integer) :: t
  def new(number_players) do
    players = Enum.reduce(1..number_players, [], fn id, players ->
      [Player.new("player_" <> to_string(id)) | players]
    end)
    %Game{active_players: players}
  end

end
