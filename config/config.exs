import Config

# tell logger to load a LoggerFileBackend processes
config :logger,
  backends: [{LoggerFileBackend, :log}]

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger, :log,
  path: "log/app.log",
  level: :debug

import_config "#{Mix.env}.exs"