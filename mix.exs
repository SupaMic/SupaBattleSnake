defmodule SupaBattleSnake.MixProject do
  use Mix.Project

  def project do
    [
      app: :supa_battle_snake,
      version: "0.1.0",
      elixir: "~> 1.9",
      # This is the default path, just adding to be more verbose
      config_path: "config/config.exs",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy, :logger_file_backend],
      mod: {SupaBattleSnake.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # This will pull in Plug AND Cowboy
      {:plug_cowboy, "~> 2.3.0"},
      # Latest version as of this writing
      {:poison, "~> 4.0.1"},
      # Latest version as of this writing
      {:logger_file_backend, "~> 0.0.11"},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
