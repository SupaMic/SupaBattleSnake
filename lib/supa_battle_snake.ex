defmodule SupaBattleSnake do
  @moduledoc """
  """
  @doc """
  """
  alias SupaBattleSnake.GameBoardStruct, as: GameBoard
  alias SupaBattleSnake.SnakeStruct, as: Snake
  alias SupaBattleSnake.GamePieces
  alias SupaBattleSnake.LegalMoves
  alias SupaBattleSnake.Strategy
  alias SupaBattleSnake.Store
  # alias SupaBattleSnake.MoveAgent
  
  @apiversion "1"
  @battlesnake_username "supamic"
  @snake_colour "#ff9900"
  @head_type "pixel"
  @tail_type "default"
  
  def convert_game_data(%{"game" => %{"id" => game_id, 
                                "timeout" => timeout_int} = _game_object, 
                    "turn" => turn_int, 
                    "board" => %{ "food" => food_list_of_maps, 
                                  "height" => height_int, 
                                  "snakes" => snakes_list_of_maps } = _board_object, 
                    "you" => %{"body" => _you_list_of_coord_maps, 
                               "head" => _you_head_coord_map, 
                               "health" => _you_health_int, 
                               "id" => you_id, 
                               "length" => _you_length_int, 
                               "name" => _you_name, 
                               "shout" => _you_shout } = _you_object } 
                    = game_params, 
                        game_state) do
                        
      #IO.inspect(game_params, label: game_state)
      
      list_of_snakes = convert_to_list_of_snakes(snakes_list_of_maps, you_id)
      #list_of_food = convert_to_coords(food_list_of_maps)
      
      game_converted = %GameBoard{game_id: game_id, timeout: timeout_int, board_height: height_int, turn: turn_int, 
                                  board_food: food_list_of_maps, you_id: you_id, snakes: list_of_snakes, route_state: game_state,
                                  up: 0.5, right: 0.5, down: 0.5, left: 0.5
                                  }
     
      #IO.inspect(game_converted, label: game_state)
  end
  
  def convert_to_list_of_snakes(snakes_list_of_maps, you_id) do
    snakes_list_of_maps
    |> Enum.map(fn map -> %Snake{body: Map.get(map, "body"), 
                           head: Map.get(map, "head"),
                           health: Map.get(map, "health"),
                           id: Map.get(map, "id"),
                           length: Map.get(map, "length"),
                           name: Map.get(map, "name"),
                           shout: Map.get(map, "shout"),
                           you: GamePieces.is_you?(Map.get(map, "id"), you_id)} end) 
    #|> IO.inspect(label: "list_of_snake_structs")
  end
  

  
  
  def optimal_move(game_data, game_state) do 
    move = game_data
      |> convert_game_data(game_state)
      |> IO.inspect(label: "optimal_move converted game_data")
      |> LegalMoves.avoid_self()
      |> LegalMoves.avoid_wall()
      |> LegalMoves.avoid_opponents()
      |> Strategy.avoid_head_to_head()
      |> Strategy.choose_adjacent_food()
      |> determine_strategic_move()
    
    %{
        "move" => move, 
        "shout" => "moving"
    }
    # MoveAgent.set_turn_move(game_data["turn"], %{
    #     "move" => move, 
    #     "shout" => "moving"
    # })
  end
  
  def determine_random_move(%GameBoard{up: up, right: right, down: down, left: left} = _game_data) do 
    %{up: up, right: right, down: down, left: left}
      |> filter_map_by_value(0.0)
      |> filter_map_less_than_value(0.0)
      |> IO.inspect(label: "filtered options")
      |> Map.keys()
      |> Enum.take_random(1)
      |> IO.inspect(label: "move")
      |> List.first()
      |> Atom.to_string()
  end
  
  def determine_strategic_move(%GameBoard{up: up, right: right, down: down, left: left} = game_data) do 
    options = %{up: up, right: right, down: down, left: left}
    
    choose_boost_or_random = boosted_option_exists?(options)
    |> IO.inspect(label: "boosted_option_exists")
    case choose_boost_or_random do
      true -> options
                |> filter_map_by_value(0.0)
                |> filter_map_less_than_value(0.0)
                |> IO.inspect(label: "filtered options")
                |> Enum.max_by(fn {_k,v}-> v end)
                |> Tuple.to_list()
                |> List.first()
                |> IO.inspect(label: "move")
                |> Atom.to_string()
      false -> determine_random_move(game_data)
    end
  end
  
  def boosted_option_exists?(options) do
    boosted = Enum.any?(options, fn {_k,v} -> v > 0.5 end)
    downgraded = Enum.any?(options, fn {_k,v} -> v < 0.5 && v > 0.0 end)
    normal = Enum.any?(options, fn {_k,v} -> v == 0.5 end)
    
    boosted || (downgraded && normal)
  end
  

  
  
  
  
  def filter_map_by_value(map, value) do
    map
    |> Enum.filter(fn {_k, v} -> v != value end)
    |> Enum.into(%{})
  end
  
  def filter_map_less_than_value(map, value) do
    map
    |> Enum.filter(fn {_k, v} -> v > value end)
    |> Enum.into(%{})
  end
  
  
  # BattleSnake API root response
  def get_snake do 
    %{
        "apiversion" => @apiversion, 
        "author" => @battlesnake_username, 
        "color" => @snake_colour,
        "head" => @head_type,
        "tail" => @tail_type
    }
  end
  
end