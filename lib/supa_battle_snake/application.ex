defmodule SupaBattleSnake.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  
  @port Application.fetch_env!(:supa_battle_snake, :port)

  def start(_type, _args) do
    children = [
      # Use Plug.Cowboy.child_spec/3 to register our endpoint as a plug
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: SupaBattleSnake.Endpoint,
        options: [port: to_port(@port)]
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
  
  defp to_port(nil) do
    Logger.error "Server can't start because :port in config is nil, please use a valid port number"
    exit(:shutdown)
  end
  defp to_port(binary)  when is_binary(binary),   do: String.to_integer(binary)
  defp to_port(integer) when is_integer(integer), do: integer
  defp to_port({:system, env_var}), do: to_port(System.get_env(env_var))
  
end
