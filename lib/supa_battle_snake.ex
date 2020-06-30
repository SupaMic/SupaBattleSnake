defmodule SupaBattleSnake.GameBoard do
  defstruct game_id: "", timeout: 500, turn: 0, board_food: [], board_height: 0, you_id: "", snakes: [], route_state: nil, up: 0.5, right: 0.5, down: 0.5, left: 0.5
end


defmodule SupaBattleSnake.Snake do
  defstruct body: [], head: %{x: 0, y: 0}, health: 100, id: "", length: 3, name: "", shout: "", you: false
end


defmodule SupaBattleSnake do
  @moduledoc """
  """
  @doc """
  """
  alias SupaBattleSnake.GameBoard
  alias SupaBattleSnake.Snake
  alias SupaBattleSnake.MoveAgent
  
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
                           you: is_you?(Map.get(map, "id"), you_id)} end) 
    #|> IO.inspect(label: "list_of_snake_structs")
  end
  
   # BattleSnake API responses
  def get_snake do 
    %{
        "apiversion" => "1", 
        "author" => "supamic", 
        "color" => "#ff9900",
        "head" => "pixel",
        "tail" => "default"
    }
  end
  
  
  def optimal_move(game_data, game_state) do 
    move = game_data
      |> convert_game_data(game_state)
      |> IO.inspect(label: "optimal_move converted game_data")
      |> avoid_self()
      |> avoid_wall()
      |> avoid_opponents()
      |> avoid_head_to_head()
      |> choose_adjacent_food()
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
  

  
  def choose_adjacent_food(%GameBoard{board_food: board_food} = game_data) do
    you_head = get_you(game_data, :head)
    
    game_data
    |> update_beneficial_moves(:up, you_head, board_food)
    |> update_beneficial_moves(:right, you_head, board_food)
    |> update_beneficial_moves(:down, you_head, board_food)
    |> update_beneficial_moves(:left, you_head, board_food)
  end
  
  def update_beneficial_moves(game_data, move, head, check_coords) do
    beneficial = check_coord_occupied?( future_coords(head, move), check_coords ) 
    case beneficial do
        true -> boost_option(game_data, move)
        false -> game_data
    end
  end
  
  def boost_option(%GameBoard{up: up, right: right, down: down, left: left} = game_data, move) do
      game_data
      |> Map.put(move, Map.fetch!(game_data, move)+0.09)
  end
  
  def avoid_self(%GameBoard{} = game_data) do
    you_head = get_you(game_data, :head)
    body = get_you(game_data, :body)
    
    you_body = body -- [List.last(body)]
    IO.puts("SELF")
    game_data
    |> update_legal_moves(:up, you_head, you_body)
    |> update_legal_moves(:right, you_head, you_body)
    |> update_legal_moves(:down, you_head, you_body)
    |> update_legal_moves(:left, you_head, you_body)
  end
  
  def avoid_wall(%GameBoard{board_height: board_height} = game_data) do
    you_head = get_you(game_data, :head)
    IO.puts("WALL")
    game_data
    |> update_legal_moves(:up, you_head, wall_coords(board_height, :top))
    |> update_legal_moves(:right, you_head, wall_coords(board_height, :right))
    |> update_legal_moves(:down, you_head, wall_coords(board_height, :bottom))
    |> update_legal_moves(:left, you_head, wall_coords(board_height, :left))
  end
  
  def wall_coords(board_height, location) do
    case location do
      :top -> Enum.map(-1..board_height, fn x -> %{"x" => x, "y" => 11 } end)
      :right -> Enum.map(-1..board_height, fn y -> %{"x" => 11, "y" => y } end)
      :bottom -> Enum.map(-1..board_height, fn x -> %{"x" => x, "y" => -1 } end)
      :left -> Enum.map(-1..board_height, fn y -> %{"x" => -1, "y" => y } end) 
    end
  end
  
  def avoid_opponents(%GameBoard{snakes: snakes, you_id: you_id} = game_data) do
    you_head = get_you(game_data, :head)
    
    combined_opponent_coords = snakes
                               |> Enum.filter(fn snake -> snake.id != you_id end)
                               |> Enum.map(fn snake -> snake.body end) 
                               |> List.flatten
    IO.puts("OPPONENTS")
    game_data
    |> update_legal_moves(:up, you_head, combined_opponent_coords)
    |> update_legal_moves(:right, you_head, combined_opponent_coords)
    |> update_legal_moves(:down, you_head, combined_opponent_coords)
    |> update_legal_moves(:left, you_head, combined_opponent_coords)
  end
  
  def avoid_head_to_head(%GameBoard{snakes: snakes} = game_data) do
    you_head = get_you(game_data, :head)
    
    combined_opponent_coords = Enum.map(snakes, fn snake -> snake.head end) |> List.flatten
    IO.puts("HEADTOHEAD")
    game_data
    |> update_legal_moves(:up_ccw, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:up_up, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:up_cw, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:right_ccw, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:right_right, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:right_cw, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:down_ccw, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:down_down, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:down_cw, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:left_ccw, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:left_left, you_head, combined_opponent_coords, :downgrade)
    |> update_legal_moves(:left_cw, you_head, combined_opponent_coords, :downgrade)
  end
  

  def remove_option(game_data, move) do
    Map.put(game_data, simplify_move(move), 0.0)
  end
  
  def update_option(game_data, move, update_value) do
    Map.put(game_data, simplify_move(move), update_value)
  end 
  
  def update_legal_moves(game_data, move, head, check_coords) do
    not_legal = check_coord_occupied?( future_coords(head, move), check_coords ) 
    case not_legal do
        true -> remove_option(game_data, move)
        false -> game_data
    end
  end
  
  def update_legal_moves(game_data, move, head, check_coords, :downgrade) do
    discouraged = check_coord_occupied?( future_coords(head, move), check_coords ) 
    simple_move = simplify_move(move)
    case discouraged do
        true -> update_option(game_data, simple_move, Map.fetch!(game_data, simple_move)-0.1)
        false -> game_data
    end
  end
  
  def simplify_move(move) do 
    case move do
      :up_ccw-> :up
      :up_up-> :up
      :up_cw-> :up
      
      :right_ccw-> :right
      :right_right-> :right
      :right_cw-> :right
      
      :down_ccw-> :down
      :down_down-> :down 
      :down_cw-> :down
      
      :left_ccw-> :left
      :left_left-> :left 
      :left_cw-> :left
      
      _ -> move
    end
  end
  
  def future_coords(%{"x" => x_coord, "y" => y_coord} = _head, potential_option) do 
    case potential_option do 
      :up -> %{"x" => x_coord, "y" => y_coord+1} |> IO.inspect(label: "future_coords(:up)")
      :right -> %{"x" => x_coord+1, "y" => y_coord} |> IO.inspect(label: "future_coords(:right)")
      :down -> %{"x" => x_coord, "y" => y_coord-1} |> IO.inspect(label: "future_coords(:down)")
      :left -> %{"x" => x_coord-1, "y" => y_coord} |> IO.inspect(label: "future_coords(:left)")
      
      :up_ccw-> %{"x" => x_coord-1, "y" => y_coord+1} |> IO.inspect(label: "future_coords(:up_ccw)")
      :up_up-> %{"x" => x_coord, "y" => y_coord+2} |> IO.inspect(label: "future_coords(:up_up)") 
      :up_cw->%{"x" => x_coord+1, "y" => y_coord+1} |> IO.inspect(label: "future_coords(:up_cw)") 
      
      :right_ccw-> %{"x" => x_coord+1, "y" => y_coord+1} |> IO.inspect(label: "future_coords(:right_ccw)")
      :right_right-> %{"x" => x_coord+2, "y" => y_coord} |> IO.inspect(label: "future_coords(:right_right)") 
      :right_cw-> %{"x" => x_coord+1, "y" => y_coord-1} |> IO.inspect(label: "future_coords(:right_cw)") 
      
      :down_ccw-> %{"x" => x_coord+1, "y" => y_coord-1} |> IO.inspect(label: "future_coords(:down_ccw)")
      :down_down-> %{"x" => x_coord, "y" => y_coord-2} |> IO.inspect(label: "future_coords(:down_down)") 
      :down_cw-> %{"x" => x_coord-1, "y" => y_coord-1} |> IO.inspect(label: "future_coords(:down_cw)") 
      
      :left_ccw-> %{"x" => x_coord-1, "y" => y_coord-1} |> IO.inspect(label: "future_coords(:left_ccw)")
      :left_left-> %{"x" => x_coord-2, "y" => y_coord} |> IO.inspect(label: "future_coords(:left_left)") 
      :left_cw-> %{"x" => x_coord-1, "y" => y_coord+1} |> IO.inspect(label: "future_coords(:left_cw)") 
      
      :up_arc -> [%{"x" => x_coord-1, "y" => y_coord+1}, %{"x" => x_coord, "y" => y_coord+2}, %{"x" => x_coord+1, "y" => y_coord+1}] |> IO.inspect(label: "future_coords(:up_arc)")
      :right_arc -> [%{"x" => x_coord+1, "y" => y_coord+1}, %{"x" => x_coord+2, "y" => y_coord}, %{"x" => x_coord+1, "y" => y_coord-1}] |> IO.inspect(label: "future_coords(:right_arc)")
      :down_arc -> [%{"x" => x_coord+1, "y" => y_coord-1}, %{"x" => x_coord, "y" => y_coord-2}, %{"x" => x_coord-1, "y" => y_coord-1}] |> IO.inspect(label: "future_coords(:down_arc)")
      :left_arc -> [%{"x" => x_coord-1, "y" => y_coord-1}, %{"x" => x_coord-2, "y" => y_coord}, %{"x" => x_coord-1, "y" => y_coord+1}] |> IO.inspect(label: "future_coords(:left_arc)")
    end
  end
  
  def check_coord_occupied?(%{"x" => _x_coord, "y" => _y_coord} = potential_coord, %{"x" => _x_coord_game, "y" => _y_coord_game} = game_coord) do
    potential_coord == game_coord
  end
  
  def check_coord_occupied?(%{"x" => _x_coord, "y" => _y_coord} = potential_coord, game_coords) when is_list(game_coords) do
    find_result = Enum.find(game_coords, fn check_coord -> check_coord == potential_coord end)
    IO.inspect(find_result, label: "check_coord_occupied?FOUND")
     
     case find_result do
        nil -> false
        _ -> true
      end
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
  
  
  def get_you(%GameBoard{snakes: snakes, you_id: you_id}) do
    you = snakes
      |> Enum.filter(fn snake -> snake.id == you_id end)
      |> List.first
  end
  
  def get_you(%GameBoard{snakes: snakes, you_id: you_id}, :head) do
    you_snake = get_you(%GameBoard{snakes: snakes, you_id: you_id})
    you_snake.head
  end
 
  def get_you(%GameBoard{snakes: snakes, you_id: you_id}, :body) do
    you_snake = get_you(%GameBoard{snakes: snakes, you_id: you_id})
    you_snake.body
  end
    
  def is_you?(id, you_id) do
    id == you_id
  end
  
end