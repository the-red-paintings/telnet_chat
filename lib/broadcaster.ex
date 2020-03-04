defmodule Broadcaster do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def register(client), do: GenServer.cast(Broadcaster, {:register, client})

  def deregister(client), do: GenServer.cast(Broadcaster, {:deregister, client})

  def broadcast(line, socket), do: GenServer.cast(Broadcaster, {:broadcast, line, socket})

  def handle_cast({:register, client}, clients), do: {:noreply, [client | clients]}

  def handle_cast({:deregister, socket}, clients) do
    {:noreply, exclude_socket(clients, socket)}
  end

  def handle_cast({:broadcast, message, socket}, clients) do
    Logger.info("Broadcasting message #{message}")

    clients
    |> exclude_socket(socket)
    |> Enum.each(&(:gen_tcp.send(&1, message)))

    {:noreply, clients}
  end

  defp exclude_socket(clients, socket) do
    Enum.filter(clients, &(&1 != socket))
  end
end
