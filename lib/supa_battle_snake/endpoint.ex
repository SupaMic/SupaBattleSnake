defmodule SupaBattleSnake.Endpoint do
  @moduledoc """
    A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """
  
  use Plug.Router
  
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
    conn
    |> send_resp(200, Poison.encode!( SupaBattleSnake.get_snake() ) )
  end
  
  # The Response to /start route is ignored by the API
  post "/start" do
  {status, body} =
      case conn.body_params do
        %{"game" => _game_object, "turn" => 0, "board" => _board_object, "you" => _you_object} -> 
            SupaBattleSnake.store_game(conn.body_params, :start)
            {200, "It Begins!"}
        _ -> {422, "422 - missing game data"}
      end

    send_resp(conn, status, body)

  end
  

  
  post "/move" do
  {status, body} =
      case conn.body_params do
        %{"game" => game_object, "turn" => turn_integer, "board" => board_object, "you" => you_object} -> 
            {200, Poison.encode!( SupaBattleSnake.make_move(game_object, turn_integer, board_object, you_object) )}
        _ -> { 200, Poison.encode!( SupaBattleSnake.make_default_move(conn.body_params) )}
      end

    send_resp(conn, status, body)

  end
  
  
  # The Response to /end route is ignored by the API
  post "/end" do
  {status, body} =
      case conn.body_params do
        %{"game" => _game_object, "turn" => _turn_integer, "board" => _board_object, "you" => _you_object} -> 
            conn.body_params
            |> SupaBattleSnake.store_game(:end)
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