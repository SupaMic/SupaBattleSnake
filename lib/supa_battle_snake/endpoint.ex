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
  
  # BattleSnake API responses
  defp get_snake do 
    %{
        "apiversion" => "1", 
        "author" => "supamic", 
        "color" => "#ff9900",
        "head" => "pixel",
        "tail" => "default"
    }
  end
  
  get "/" do
    conn
    |> send_resp(200, Poison.encode!( get_snake() ) )
  end
  
  # The Response to /start route is ignored by the API
  post "/start" do
  {status, body} =
      case conn.body_params do
        %{"game" => _game_object, "turn" => 0, "board" => _board_object, "you" => _you_object} -> 
            store_game(conn.body_params, :start)
            {200, "It Begins!"}
        _ -> {422, "422 - missing game data"}
      end

    send_resp(conn, status, body)

  end
  
    
  defp make_default_move(post_data) do 
    post_data
    |> IO.inspect(label: "made a default move up")
    
    %{
        "move" => "up", 
        "shout" => "AHHH ERROR, move up I guess"
    }
  end
  
 defp make_move(game_object, turn, board_object, you_object) do 
 
    {game_object, turn, board_object, you_object}
    |> IO.inspect(label: "make_move")
    
    %{
        "move" => "left", 
        "shout" => "highly strategic move"
    }
  end
  
  post "/move" do
  {status, body} =
      case conn.body_params do
        %{"game" => game_object, "turn" => turn_integer, "board" => board_object, "you" => you_object} -> 
            {200, Poison.encode!( make_move(game_object, turn_integer, board_object, you_object) )}
        _ -> { 200, Poison.encode!( make_default_move(conn.body_params) )}
      end

    send_resp(conn, status, body)

  end
  
  
  # The Response to /end route is ignored by the API
  post "/end" do
  {status, body} =
      case conn.body_params do
        %{"game" => _game_object, "turn" => _turn_integer, "board" => _board_object, "you" => _you_object} -> 
            conn.body_params
            |> store_game(:end)
            {200, "Game End"}
        _ -> { 200, "Game End - missing game data"}
      end

    send_resp(conn, status, body)
  end
  
  
  defp store_game(game_params, game_state) do
     # Faux storage for now
     game_params
     |> IO.inspect(label: game_state)
     
  end
  
  
  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    send_resp(conn, 404, "404 - Route Not Found\n")
  end

end