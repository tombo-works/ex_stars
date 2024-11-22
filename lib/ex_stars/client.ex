defmodule ExSTARS.Client do
  @moduledoc false

  use GenServer

  require Logger

  def send(message) do
    send_with_name(__MODULE__, message)
  end

  def send_with_name(name, message) do
    GenServer.call(name(name), {:send, "#{message}\n"})
  end

  def update_callback_pid(callback_pid) do
    update_callback_pid_with_name(__MODULE__, callback_pid)
  end

  def update_callback_pid_with_name(name, callback_pid) do
    GenServer.call(name(name), {:update_callback_pid, callback_pid})
  end

  def name(name) do
    {:via, Registry, {ExSTARS.Registry, name}}
  end

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, name: name(name))
  end

  def init(args) do
    name = Keyword.get(args, :name, __MODULE__)
    key = if not (name == __MODULE__), do: Keyword.fetch!(args, :key)

    transport = Keyword.get(args, :transport, :gen_tcp)
    address = Keyword.get(args, :address, {127, 0, 0, 1})
    port = Keyword.get(args, :port, 6057)
    callback_pid = Keyword.fetch!(args, :callback_pid)

    {:ok,
     %{
       name: name,
       key: key,
       transport: transport,
       address: address,
       port: port,
       callback_pid: callback_pid,
       socket: nil,
       reconnection_attempts: 0
     }, {:continue, :connect}}
  end

  def handle_continue(:connect, state) do
    %{
      name: name,
      transport: transport,
      address: address,
      port: port,
      reconnection_attempts: reconnection_attempts
    } = state

    case connect(transport, address, port) do
      {:ok, socket} ->
        if name == __MODULE__ do
          {:noreply, %{state | socket: socket, reconnection_attempts: 0}}
        else
          {:noreply, %{state | socket: socket, reconnection_attempts: 0}, {:continue, :send}}
        end

      {:error, reason} ->
        Logger.error(":connect failed, the reason is #{inspect(reason)}")
        Process.send_after(self(), :reconnect, wait_time(reconnection_attempts))
        {:noreply, state}
    end
  end

  def handle_continue(:send, state) do
    %{name: name, key: key, transport: transport, socket: socket} = state

    case transport.send(socket, "#{name} #{key}\n") do
      :ok ->
        {:noreply, state}

      {:error, :closed = reason} ->
        Logger.error(":send failed, the reason is #{inspect(reason)}")
        {:noreply, state, {:continue, :connect}}

      {:error, reason} ->
        Logger.error(":send failed, the reason is #{inspect(reason)}")
        {:noreply, state}
    end
  end

  def handle_call({:send, message}, _from, state) do
    %{transport: transport, socket: socket} = state

    if is_nil(socket) do
      Logger.error(":send failed, the reason is not connected")
      {:reply, {:error, :send_failed}, state, {:continue, :connect}}
    else
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
  end

  def handle_call({:update_callback_pid, callback_pid}, _from, state) do
    {:reply, :ok, %{state | callback_pid: callback_pid}}
  end

  def handle_info(:reconnect, state) do
    %{reconnection_attempts: reconnection_attempts} = state
    new_state = %{state | reconnection_attempts: reconnection_attempts + 1}
    {:noreply, new_state, {:continue, :connect}}
  end

  def handle_info({:tcp, _port, message}, state) do
    %{name: name, callback_pid: callback_pid} = state

    message
    |> tap(&Logger.debug("#{&1}"))
    |> then(&send(callback_pid, {__MODULE__, name, &1}))

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _port}, state) do
    %{transport: transport, socket: socket} = state
    Logger.error(":tcp_closed")
    :ok = transport.close(socket)
    {:noreply, %{state | socket: nil}, {:continue, :connect}}
  end

  defp connect(:gen_tcp, address, port) do
    :gen_tcp.connect(
      address,
      port,
      [mode: :binary, packet: :raw, active: true],
      _timeout = 3000
    )
  end

  defp wait_time(reconnection_attempts, jitter_max \\ 1000) do
    wait_time = min(:math.pow(2, reconnection_attempts), 16.0) * 1000
    jitter = :rand.uniform(jitter_max)
    round(wait_time + jitter)
  end
end
