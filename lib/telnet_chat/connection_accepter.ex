defmodule TelnetChat.ConnectionAccepter do
  use GenServer
  require Logger

  alias TelnetChat.Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    {:ok, state, {:continue, :start}}
  end

  defp loop_acceptor(socket) do
    GenServer.cast(self(), {:loop_acceptor, socket})
  end


  def handle_continue(:start, state) do
    accept(4040)

    {:noreply, state}
  end

  def handle_cast({:loop_acceptor, socket}, state) do
    {:ok, client} = :gen_tcp.accept(socket)

    Logger.info("New client connected ")

    Client.start_link(client)

    loop_acceptor(socket)

    {:noreply, state}
  end

  defp accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")

    loop_acceptor(socket)
  end

end
