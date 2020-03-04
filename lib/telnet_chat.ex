defmodule TelnetChat do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    GenServer.cast(self(), {:start, state})

    {:ok, state}
  end

  def handle_cast({:start, state}, state) do
    accept(4040)

    {:noreply, []}
  end

  defp accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")

    loop_accept(socket)
  end

  defp loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    Logger.info("New client connected ")

    Client.start_link(client)

    loop_accept(socket)
  end
end
