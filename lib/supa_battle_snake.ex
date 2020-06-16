defmodule SupaBattleSnake.GameBoard do
  defstruct game_id: "", timeout: 500, turn: 0, board_food: [], board_height: 0, you_id: "", snakes: [], route_state: nil, up: 1.0, right: 1.0, down: 1.0, left: 1.0
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
      list_of_food = convert_to_coords(food_list_of_maps)
      
      game_converted = %GameBoard{game_id: game_id, timeout: timeout_int, board_height: height_int, turn: turn_int, 
                                  board_food: list_of_food, you_id: you_id, snakes: list_of_snakes, route_state: game_state,
                                  up: 1.0, right: 1.0, down: 1.0, left: 1.0
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
  
  def is_you?(id, you_id) do
    id == you_id
  end
  
  def convert_to_coords(list_of_coord_maps) do 
    Enum.map(list_of_coord_maps, fn map -> [x: Map.get(map, "x"), y: Map.get(map, "y")] end) 
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
    |> determine_move()
    
    %{
        "move" => move, 
        "shout" => "highly strategic not random move"
    }
  end
  
  def determine_move(%GameBoard{up: up, right: right, down: down, left: left} = _game_data) do 
    %{up: up, right: right, down: down, left: left}
    |> filter_map_by_value(0.0)
    |> IO.inspect(label: "filtered options")
    |> Map.keys()
    |> Enum.take_random(1)
    |> IO.inspect(label: "move")
    |> List.first()
    |> Atom.to_string()
    
  end
  
  def avoid_self(%GameBoard{} = game_data) do
  
    you_head = get_you(game_data, :head)
    you_body = get_you(game_data, :body)
    
    game_data
    |> update_legal_moves(:up, you_head, you_body)
    |> update_legal_moves(:right, you_head, you_body)
    |> update_legal_moves(:down, you_head, you_body)
    |> update_legal_moves(:left, you_head, you_body)
    
  end
  
  def avoid_wall(%GameBoard{board_height: board_height} = game_data) do
    
    you_head = get_you(game_data, :head)
    
    game_data
    |> update_legal_moves(:up, you_head, wall_coords(board_height, :top))
    |> update_legal_moves(:right, you_head, wall_coords(board_height, :right))
    |> update_legal_moves(:down, you_head, wall_coords(board_height, :bottom))
    |> update_legal_moves(:left, you_head, wall_coords(board_height, :left))
    
  end
  
  def avoid_opponents(%GameBoard{snakes: snakes} = game_data) do
    
    IO.inspect(game_data, label: "avoid_opponents initial game_data")
    
    you_head = get_you(game_data, :head)
    
    Enum.map(snakes, fn snake -> game_data
                                  |> update_legal_moves(:up, you_head, snake.body)
                                  |> update_legal_moves(:right, you_head, snake.body)
                                  |> update_legal_moves(:down, you_head, snake.body)
                                  |> update_legal_moves(:left, you_head, snake.body)
                                  end ) 
    |> IO.inspect(label: "avoid_opponents -> Enum.each result")
    
    game_data
    |> IO.inspect(label: "avoid_opponents final game_data")
    
  end
  
  def wall_coords(board_height, location) do

    case location do
      :top -> Enum.map(1..board_height-1, fn x -> %{"x" => x, "y" => 10 } end)
      :right -> Enum.map(1..board_height-1, fn y -> %{"x" => 10, "y" => y } end)
      :bottom -> Enum.map(1..board_height-1, fn x -> %{"x" => x, "y" => 1 } end)
      :left -> Enum.map(1..board_height-1, fn y -> %{"x" => 1, "y" => y } end) 
    end
  end
  
  def remove_option(game_data, move) do
    Map.put(game_data, move, 0.0)
  end
 
  def update_option(game_data, move, update_value) do
    Map.put(game_data, move, update_value)
  end 
  
  def update_legal_moves(game_data, move, head, check_coords) do
  
    not_legal = check_coord_occupied?( future_coords(head, move), check_coords ) 
    case not_legal do
        true -> remove_option(game_data, move)
        false -> game_data
    end
    
  end
  
  
  def future_coords(%{"x" => x_coord, "y" => y_coord} = _head, potential_option) do 
    case potential_option do 
      :up -> %{"x" => x_coord, "y" => y_coord+1} |> IO.inspect(label: "future_coords(:up)")
      :right -> %{"x" => x_coord+1, "y" => y_coord} |> IO.inspect(label: "future_coords(:right)")
      :down -> %{"x" => x_coord, "y" => y_coord-1} |> IO.inspect(label: "future_coords(:down)")
      :left -> %{"x" => x_coord-1, "y" => y_coord} |> IO.inspect(label: "future_coords(:left)")
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
    #:maps.filter fn _, v -> v != value end, map
    map
    |> Enum.filter(fn {_k, v} -> v != value end)
    |> Enum.into(%{})
    
  end
 
  def get_you(%GameBoard{snakes: snakes, you_id: you_id}) do
    you = snakes
    |> IO.inspect(label: "all snakes")
    |> Enum.filter(fn snake -> snake.id == you_id end)
    #|> IO.inspect(label: "you snake")
    |> List.first
    you
  end
  
  def get_you(%GameBoard{snakes: snakes, you_id: you_id}, :head) do
    you_snake = get_you(%GameBoard{snakes: snakes, you_id: you_id})
    you_snake.head
  end
 
  def get_you(%GameBoard{snakes: snakes, you_id: you_id}, :body) do
    you_snake = get_you(%GameBoard{snakes: snakes, you_id: you_id})
    you_snake.body
  end
  

 
  def demo_snakes() do
    [
      %SupaBattleSnake.Snake{
        body: [
          %{"x" => 2, "y" => 2},
          %{"x" => 2, "y" => 3},
          %{"x" => 2, "y" => 4},
          %{"x" => 3, "y" => 4},
          %{"x" => 3, "y" => 3},
          %{"x" => 4, "y" => 3},
          %{"x" => 5, "y" => 3},
          %{"x" => 6, "y" => 3}
        ],
        head: %{"x" => 2, "y" => 2},
        health: 62,
        id: "gs_rYbkTXbpSgMQvvfQfpCRhgYb",
        length: 8,
        name: "ignatius",
        shout: "",
        you: false
      },
      %SupaBattleSnake.Snake{
        body: [
          %{"x" => 4, "y" => 4},
          %{"x" => 4, "y" => 5},
          %{"x" => 4, "y" => 6},
          %{"x" => 4, "y" => 7}
        ],
        head: %{"x" => 4, "y" => 4},
        health: 94,
        id: "gs_mYfHbCgBCPrwbVTcbtbv7yBW", 
        length: 4,
        name: "Alpha_Tester",
        shout: "highly strategic not random move",
        you: true
      }
    ]
    end
  
  
end



  
  
  # def avoid_opponents_rule(%GameBoard{snakes: snakes} = game_data) do
    
  #   opponent_snakes = snakes
  #   |> Enum.filter(fn snake -> snake.you == false end)
  #   |> IO.inspect(label: "opponent_snakes list")
    
    
  #   Enum.map(snakes, fn snake -> check_if_path_in_body(game_data, get_you(game_data, :head), snake.body) end)
    
  # end
  
  
  
  # def is_path_in_body?(%{"x" => _x, "y" => _y} = path, body) do
  #   find_result = Enum.find(body, fn body_segment -> body_segment == path end)
  #   IO.inspect(find_result, label: "is_path_in_body?=")
     
  #   case find_result do
  #       nil -> false
  #       _ -> true
  #     end
  # end
  

  
  
  # def wall_rule(%GameBoard{snakes: snakes, you_id: you_id} = game_data) do
    
  #   head = get_you(game_data, :head)
    
  #   IO.inspect(get_you(game_data), label: "wall_rule - you")
    
  #   options = 
  #     case head["x"] do
  #         1  -> remove_option(options, :left)
  #         10 -> remove_option(options, :right)
  #         _ -> IO.inspect(options, label: "No collision left or right wall")
  #     end
    
  #   IO.inspect(options, label: "wall_rule - options after head_x case")
    
  #   options =
  #     case head["y"] do
  #         1  -> remove_option(options, :down)
  #         10 -> remove_option(options, :up)
  #         _ ->  IO.inspect(options, label: "No collision bottom or top wall")
  #     end
      
  #   IO.inspect(options, label: "wall_rule - options after head_y case")
    
  #   Map.put(game_data, :options, options)
    
  # end
  # def check_vertical_path(options, %{"x" => head_x, "y" => head_y} = head, body) do 
  #   new_options = options
  #     cond do
  #       is_path_in_body?(%{"x" => head_x, "y" => head_y+1}, body)  -> remove_option(options, :up)
  #       is_path_in_body?(%{"x" => head_x, "y" => head_y-1}, body)  -> remove_option(options, :down)
  #       true -> options
  #     end
  # end
  
  
  # def check_horizontal_path(options, %{"x" => head_x, "y" => head_y} = head, body) do 
  #   new_options = options
  #     cond do
  #       is_path_in_body?(%{"x" => head_x+1, "y" => head_y}, body)  -> remove_option(options, :right)
  #       is_path_in_body?(%{"x" => head_x-1, "y" => head_y}, body)  -> remove_option(options, :left)
  #       true -> options
  #     end
  # end
 
  # def avoid_self_rule(%GameBoard{snakes: snakes, you_id: you_id, options: options} = game_data) do
  
  #   head = get_you(%GameBoard{snakes: snakes, you_id: you_id}, :head)
  #   body = get_you(%GameBoard{snakes: snakes, you_id: you_id}, :body)
    
  #   new_options = options
  #     |> check_vertical_path(head, body)
  #     |> IO.inspect(label: "avoid_self_rule - options after vertical check")
  #     |> check_horizontal_path(head, body)
  #     |> IO.inspect(label: "avoid_self_rule - options after horizontal check")
      
  #     Map.put(game_data, :options, new_options)
    
  # end
  
  # def check_if_path_in_body(%GameBoard{options: options} = game_data, head, body) do
  #     new_options = options
  #     |> check_vertical_path(head, body)
  #     |> IO.inspect(label: "opponents - options after vertical check")
  #     |> check_horizontal_path(head, body)
  #     |> IO.inspect(label: "opponents - options after horizontal check")
      
  # end