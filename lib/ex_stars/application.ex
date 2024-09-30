defmodule ExSTARS.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: client_supervisor_name(), strategy: :one_for_one}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @doc false
  def client_supervisor_name(), do: ExSTARS.ClientSupervisor
end
