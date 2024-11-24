defmodule ExSTARS.TransportBehaviour do
  @moduledoc false

  _ = """
  This behaviour provides the exact same interface as :gen_tcp.

  We use `identifier()` as socket type for unit tests.
  """

  @callback connect(
              address :: :inet.socket_address() | :inet.hostname(),
              port :: :inet.port_number(),
              opts :: [:inet.inet_backend() | :gen_tcp.connect_option()],
              timeout :: timeout()
            ) :: {:ok, socket :: identifier()} | {:error, :timeout | :inet.posix()}

  @callback close(socket :: identifier()) :: :ok

  @callback send(socket :: identifier(), packet :: iodata()) ::
              :ok | {:error, :closed | {:timeout, rest_data :: binary()} | :inet.posix()}
end
