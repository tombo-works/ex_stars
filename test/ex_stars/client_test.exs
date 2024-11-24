defmodule ExSTARS.ClientTest do
  use ExUnit.Case

  import Mox

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    :ok = Application.stop(:ex_stars)
    on_exit(fn -> :ok = Application.ensure_started(:ex_stars) end)

    {:ok, _pid} =
      start_supervised({Registry, keys: :unique, name: ExSTARS.Registry}, restart: :temporary)

    %{me: self()}
  end

  describe "start_link/1" do
    test "without name, :connect return :ok tuple", context do
      ExSTARS.TransportMock
      |> expect(:connect, fn _address, _port, _opts, _timeout ->
        send(context.me, :wait)
        {:ok, make_ref()}
      end)

      assert {:ok, _pid} =
               ExSTARS.Client.start_link(transport: ExSTARS.TransportMock, callback_pid: self())

      assert_receive :wait
      assert ExSTARS.Client.name(ExSTARS.Client) |> GenServer.whereis() |> GenServer.stop() == :ok
    end

    test "without name, 1st :connect return :error tuple", context do
      ExSTARS.TransportMock
      |> expect(:connect, fn _address, _port, _opts, _timeout -> {:error, :econnrefused} end)
      |> expect(:connect, fn _address, _port, _opts, _timeout ->
        send(context.me, :wait)
        {:ok, make_ref()}
      end)

      assert {:ok, _pid} =
               ExSTARS.Client.start_link(
                 transport: ExSTARS.TransportMock,
                 callback_pid: self(),
                 reconnection_step_time: 1
               )

      assert_receive :wait
      assert ExSTARS.Client.name(ExSTARS.Client) |> GenServer.whereis() |> GenServer.stop() == :ok
    end

    test "with name, :connect return :ok tuple, :send return :ok", context do
      ExSTARS.TransportMock
      |> expect(:connect, fn _address, _port, _opts, _timeout -> {:ok, make_ref()} end)
      |> expect(:send, fn _socket, "term1 stars\n" ->
        send(context.me, :wait)
        :ok
      end)

      assert {:ok, _pid} =
               ExSTARS.Client.start_link(
                 name: "term1",
                 key: "stars",
                 transport: ExSTARS.TransportMock,
                 callback_pid: context.me,
                 reconnection_step_time: 1
               )

      assert_receive :wait
      assert ExSTARS.Client.name("term1") |> GenServer.whereis() |> GenServer.stop() == :ok
    end

    test "with name, :connect return :ok tuple, :send return :error tuple", context do
      ExSTARS.TransportMock
      |> expect(:connect, fn _address, _port, _opts, _timeout -> {:ok, make_ref()} end)
      |> expect(:send, fn _socket, "term1 stars\n" -> {:error, :closed} end)
      |> expect(:close, fn _socket -> :ok end)
      |> expect(:connect, fn _address, _port, _opts, _timeout -> {:ok, make_ref()} end)
      |> expect(:send, fn _socket, "term1 stars\n" ->
        send(context.me, :wait)
        :ok
      end)

      assert {:ok, _pid} =
               ExSTARS.Client.start_link(
                 name: "term1",
                 key: "stars",
                 transport: ExSTARS.TransportMock,
                 callback_pid: context.me,
                 reconnection_step_time: 1
               )

      assert_receive :wait
      assert ExSTARS.Client.name("term1") |> GenServer.whereis() |> GenServer.stop() == :ok
    end

    test "multiple clients", context do
      ExSTARS.TransportMock
      |> expect(:connect, fn _address, _port, _opts, _timeout -> {:ok, make_ref()} end)
      |> expect(:connect, fn _address, _port, _opts, _timeout -> {:ok, make_ref()} end)
      |> expect(:send, fn _socket, _message -> :ok end)
      |> expect(:send, fn _socket, _message ->
        send(context.me, :wait)
        :ok
      end)

      assert {:ok, _pid} =
               ExSTARS.Client.start_link(
                 name: "term1",
                 key: "stars",
                 transport: ExSTARS.TransportMock,
                 callback_pid: context.me
               )

      assert {:ok, _pid} =
               ExSTARS.Client.start_link(
                 name: "term2",
                 key: "stars",
                 transport: ExSTARS.TransportMock,
                 callback_pid: context.me
               )

      assert_receive :wait
      assert ExSTARS.Client.name("term1") |> GenServer.whereis() |> GenServer.stop() == :ok
      assert ExSTARS.Client.name("term2") |> GenServer.whereis() |> GenServer.stop() == :ok
    end
  end

  describe "send/1" do
    setup do
      transport =
        ExSTARS.TransportMock
        |> expect(:connect, fn _address, _port, _opts, _timeout -> {:ok, make_ref()} end)

      {:ok, client_pid} =
        start_supervised(
          {ExSTARS.Client, transport: transport, callback_pid: self(), reconnection_step_time: 1},
          restart: :temporary
        )

      %{client_pid: client_pid, transport: transport}
    end

    test "return :ok", context do
      context.transport
      |> expect(:send, fn _socket, "term1 stars\n" -> :ok end)

      assert ExSTARS.Client.send("term1 stars") == :ok
    end

    test "return {:error, :send_failed}", context do
      context.transport
      |> expect(:send, fn _socket, "term1 stars\n" -> {:error, :closed} end)
      |> expect(:close, fn _socket -> :ok end)
      |> expect(:connect, fn _address, _port, _opts, _timeout ->
        send(context.me, :wait)
        {:ok, make_ref()}
      end)

      assert ExSTARS.Client.send("term1 stars") == {:error, :send_failed}
      assert_receive :wait
    end

    test "return {:error, :send_failed} when socket is nil", context do
      context.transport
      |> expect(:close, fn _socket -> :ok end)
      |> expect(:connect, fn _address, _port, _opts, _timeout ->
        send(context.me, :wait)
        {:ok, make_ref()}
      end)

      send(context.client_pid, {:tcp_closed, make_ref()})

      assert ExSTARS.Client.send("term1 stars") == {:error, :send_failed}
      assert_receive :wait
    end
  end

  describe "update_callback_pid/1" do
    setup do
      transport =
        ExSTARS.TransportMock
        |> expect(:connect, fn _address, _port, _opts, _timeout -> {:ok, make_ref()} end)

      {:ok, client_pid} =
        start_supervised(
          {ExSTARS.Client, transport: transport, callback_pid: self(), reconnection_step_time: 1},
          restart: :temporary
        )

      %{client_pid: client_pid}
    end

    test "return :ok", context do
      send(context.client_pid, {:tcp, make_ref(), "test"})
      assert_receive {ExSTARS.Client, ExSTARS.Client, "test"}

      assert ExSTARS.Client.update_callback_pid(:erlang.list_to_pid(~c"<0.12.34>")) == :ok

      send(context.client_pid, {:tcp, make_ref(), "test"})
      refute_receive {ExSTARS.Client, ExSTARS.Client, "test"}
    end
  end
end
