defmodule TelnetChat.Client do
  use GenServer
  require Logger

  alias TelnetChat.Client
  alias TelnetChat.Broadcaster

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(client_socket) do
    Broadcaster.register(client_socket)

    {:ok, client_socket, {:continue, :serve}}
  end

  def stop() do
    GenServer.cast(self(), :stop)
  end

  def loop_serve() do
    GenServer.cast(self(), :serve)
  end

  def handle_continue(:serve, client_socket) do
    serve(client_socket)

    loop_serve()
    {:noreply, client_socket}
  end

  def handle_cast(:stop, state), do: {:stop, :normal, state}

  def handle_cast(:serve, client_socket) do
    serve(client_socket)

    loop_serve()
    {:noreply, client_socket}
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> deregister(socket)
    |> write_line(socket)

    :ok
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "client error"}
    end
  end

  defp deregister({:error, reason}, socket) do
    Broadcaster.deregister(socket)
    Client.stop()

    {:error, reason}
  end

  defp deregister({:ok, data}, _), do: {:ok, data}

  defp write_line({:error, reason}, _), do: reason

  defp write_line({:ok, data}, socket), do: Broadcaster.broadcast(data, socket)

end
