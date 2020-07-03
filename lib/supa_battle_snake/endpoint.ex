defmodule SupaBattleSnake.Endpoint do
  @moduledoc """
    A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """
  
  use Plug.Router
  require Logger
  #alias SupaBattleSnake.MoveAgent
  
    # This module is a Plug, that also implements it's own plug pipeline, below:

  # Using Plug.Logger for logging request information
  plug(Plug.Logger)
  # responsible for matching routes
  plug(:match)
  
  # Using Poison for JSON decoding
  # Note, order of plugs is important, by placing this _after_ the 'match' plug,
  # we will only parse the request AFTER there is a route match.
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  # responsible for dispatching responses
  plug(:dispatch)
  
  # A simple route to test that the server is up
  # Note, all routes must return a connection as per the Plug spec.
  get "/ping" do
    send_resp(conn, 200, "pong!")
  end
  
  
  get "/" do
    Logger.info "Server root pinged"
    conn
    |> send_resp(200, Poison.encode!( SupaBattleSnake.get_snake() ) )
  end
  
  # The Response to /start route is ignored by the API
  post "/start" do
  {status, body} =
      case conn.body_params do
        %{"game" => _game_object, "turn" => _turn_int, "board" => _board_object, "you" => _you_object} -> 
            conn.body_params
            |> Poison.encode!()
            |> String.Chars.to_string()
            |> Logger.info()
            
            {200, "It Begins!"}
        _ -> {422, "422 - missing game data"}
      end

    send_resp(conn, status, body)

  end
  

  
  post "/move" do
  {status, body} =
      case conn.body_params do
        %{"game" => _game_object, "turn" => _turn_int, "board" => _board_object, "you" => _you_object} -> 
            
            move = SupaBattleSnake.optimal_move(conn.body_params, :move)
            #{:ok, move} = MoveAgent.get_turn_move(turn_int)
            
            {200, Poison.encode!( move )}
        _ -> { 200, Poison.encode!( "" )}
      end

    send_resp(conn, status, body)

  end
  
  
  # The Response to /end route is ignored by the API
  post "/end" do
  {status, body} =
      case conn.body_params do
        %{"game" => _game_object, "turn" => _turn_int, "board" => _board_object, "you" => _you_object} -> 
            conn.body_params
            |> SupaBattleSnake.convert_game_data(:end)
            |> IO.inspect(label: "route: /end\ngame_data")
            #SupaBattleSnake.MoveAgent.remove_moves
            {200, "Game End"}
        _ -> { 200, "Game End - missing game data"}
      end

    send_resp(conn, status, body)
  end
  
  
  
  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    send_resp(conn, 404, "404 - Route Not Found\n")
  end
  

end