defmodule Client do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(client_socket) do
    Broadcaster.register(client_socket)
    Client.serve()

    {:ok, client_socket}
  end

  def stop(), do: GenServer.cast(self(), :stop)

  def serve(), do: GenServer.cast(self(), :serve)

  def handle_cast(:stop, state), do: {:stop, :normal, state}

  def handle_cast(:serve, client_socket) do
    serve(client_socket)

    {:noreply, client_socket}
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> deregister(socket)
    |> write_line(socket)

    serve socket
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> data
      _ -> :deregister
    end
  end

  defp deregister(:deregister, socket) do
    Broadcaster.deregister(socket)
    Client.stop()

    :closed
  end

  defp deregister(data, _), do: data

  defp write_line(:closed, _), do: :closed

  defp write_line(line, socket), do: Broadcaster.broadcast(line, socket)
end
