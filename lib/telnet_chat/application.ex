defmodule TelnetChat.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {TelnetChat, 4040},
      {Broadcaster, []}
    ]

    opts = [strategy: :one_for_all, name: TelnetChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
