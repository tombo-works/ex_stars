defmodule ExSTARS.Client do
  @moduledoc false

  use GenServer

  require Logger

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def send(message), do: send_with_name(__MODULE__, message)

  def send_with_name(name, message) do
    GenServer.call(name, {:send, "#{message}\n"})
  end

  def init(args) do
    transport = Keyword.get(args, :transport, :gen_tcp)
    address = Keyword.get(args, :address, {127, 0, 0, 1})
    port = Keyword.get(args, :port, 6057)

    {:ok,
     %{
       transport: transport,
       address: address,
       port: port,
       socket: nil
     }, {:continue, :connect}}
  end

  def handle_continue(:connect, state) do
    %{transport: transport, address: address, port: port} = state

    case connect(transport, address, port) do
      {:ok, socket} ->
        {:noreply, %{state | socket: socket}}

      {:error, _reason} ->
        {:noreply, state, {:continue, :connect}}
    end
  end

  def handle_call({:send, message}, _from, state) do
    %{transport: transport, socket: socket} = state

    case transport.send(socket, message) do
      :ok ->
        {:reply, :ok, state}

      {:error, :closed = reason} ->
        Logger.error(":send failed, the reason is #{inspect(reason)}")
        {:reply, {:error, :send_failed}, state, {:continue, :connect}}

      {:error, reason} ->
        Logger.error(":send failed, the reason is #{inspect(reason)}")
        {:reply, {:error, :send_failed}, state}
    end
  end

  def handle_info({:tcp, _port, message}, state) do
    Logger.info("""
    STARS server:
    #{String.trim_trailing(message)}
    """)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _port}, state) do
    Logger.error(":tcp_closed")
    {:noreply, state, {:continue, :connect}}
  end

  defp connect(:gen_tcp, address, port) do
    :gen_tcp.connect(
      address,
      port,
      [mode: :binary, packet: :raw, active: true],
      _timeout = 3000
    )
  end
end
