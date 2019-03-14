defmodule Schocken.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Schocken.Server, 3}
    ]

    opts = [strategy: :one_for_one, name: Schocken.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
