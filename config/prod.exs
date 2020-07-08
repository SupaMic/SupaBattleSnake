import Config

config :supa_battle_snake, 
    port: 4000, 
    scheme: :https
    http: [port: {:system, "PORT"}]
