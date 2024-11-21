defmodule ExSTARS do
  @moduledoc """
  Documentation for `ExSTARS`.
  """

  @doc """
  Start STARS client.

  ## Example

      iex> ExSTARS.start_client({127, 0, 0, 1}, 6057)
      :ok

  """
  @spec start_client(
          address :: :inet.socket_address() | :inet.hostname(),
          port :: :inet.port_number(),
          callback_pid :: pid()
        ) :: :ok | {:error, :already_started}
  def start_client(address, port, callback_pid \\ self()) do
    case DynamicSupervisor.start_child(
           ExSTARS.Application.client_supervisor_name(),
           {ExSTARS.Client, [address: address, port: port, callback_pid: callback_pid]}
         ) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        ExSTARS.Client.update_callback_pid(callback_pid)
        {:error, :already_started}
    end
  end

  @doc """
  Start STARS client.

  ## Example

      iex> ExSTARS.start_client("term1", "stars", {127, 0, 0, 1}, 6057)
      :ok

  """
  @spec start_client(
          name :: String.t(),
          key :: String.t(),
          address :: :inet.socket_address() | :inet.hostname(),
          port :: :inet.port_number(),
          callback_pid :: pid()
        ) :: :ok | {:error, :already_started}
  def start_client(name, key, address, port, callback_pid \\ self()) do
    case DynamicSupervisor.start_child(
           ExSTARS.Application.client_supervisor_name(),
           {ExSTARS.Client,
            [name: name, key: key, address: address, port: port, callback_pid: callback_pid]}
         ) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        ExSTARS.Client.update_callback_pid_with_name(name, callback_pid)
        {:error, :already_started}
    end
  end

  @doc """
  Send a message.

  ## Example

      iex> ExSTARS.send("term1 stars")
      :ok
      iex> ExSTARS.send("System help")
      :ok

  """
  @spec send(message :: String.t()) :: :ok | {:error, :send_failed}
  defdelegate send(message), to: ExSTARS.Client

  @doc """
  Send a message using the specified client.

  ## Example

      iex> ExSTARS.send("term1", "System help")
      :ok

  """
  @spec send(name :: String.t(), message :: String.t()) :: :ok | {:error, :send_failed}
  defdelegate send(name, message), to: ExSTARS.Client, as: :send_with_name
end
