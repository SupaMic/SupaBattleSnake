defmodule SupaBattleSnake.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
     # Use Plug.Cowboy.child_spec/3 to register our endpoint as a plug
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: SupaBattleSnake.Endpoint,
        options: [port: 4001]
      )
      # Starts a worker by calling: SupaBattleSnake.Worker.start_link(arg)
      # {SupaBattleSnake.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SupaBattleSnake.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
