defmodule ExSTARS do
  @moduledoc """
  Documentation for `ExSTARS`.
  """

  @type client :: GenServer.name()

  @spec start_client(
          name :: client(),
          address :: :inet.socket_address() | :inet.hostname(),
          port :: :inet.port_number()
        ) :: :ok | {:error, :already_started}
  def start_client(name \\ ExSTARS.Client, address, port) do
    case DynamicSupervisor.start_child(
           ExSTARS.Application.client_supervisor_name(),
           {ExSTARS.Client, [name: name, address: address, port: port]}
         ) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_started}
    end
  end

  @spec send(name :: GenServer.name(), message :: String.t()) :: :ok | {:error, :send_failed}
  def send(name \\ ExSTARS.Client, message) do
    ExSTARS.Client.send_with_name(name, message)
  end
end
