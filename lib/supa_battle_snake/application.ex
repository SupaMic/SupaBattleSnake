defmodule SupaBattleSnake.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    children = [
      # Use Plug.Cowboy.child_spec/3 to register our endpoint as a plug
      Plug.Cowboy.child_spec(
        scheme: Application.fetch_env!(:supa_battle_snake, :scheme),
        plug: SupaBattleSnake.Endpoint,
        options: [port: Application.fetch_env!(:supa_battle_snake, :port)]
      ),
      SupaBattleSnake.MoveAgent
      # Starts a worker by calling: SupaBattleSnake.Worker.start_link(arg)
      # {SupaBattleSnake.Worker, arg}
    ]

    Logger.info("Application Starting...")
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SupaBattleSnake.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
