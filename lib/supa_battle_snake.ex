defmodule SupaBattleSnake do
  @moduledoc """
  Documentation for SupaBattleSnake.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SupaBattleSnake.hello()
      :world

  """
  def hello do
    :world
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
  
    
    
  def make_default_move(post_data) do 
    post_data
    |> IO.inspect(label: "made a default move up")
    
    %{
        "move" => "up", 
        "shout" => "AHHH ERROR, move up I guess"
    }  
  end
  
  
  
 def make_move(game_object, turn, board_object, you_object) do 
 
    {game_object, turn, board_object, you_object}
    |> IO.inspect(label: "make_move")
    
    move = %{up: true, right: true, down: true, left: true}
    |> avoid_self_rule(you_object)
    |> wall_rule(you_object)
    |> filter_map_by_value(false)
    |> IO.inspect(label: "filtered options")
    |> Map.keys()
    |> Enum.take_random(1)
    |> IO.inspect(label: "move")
    |> List.first()
    |> Atom.to_string()

    
    
    
    %{
        "move" => move, 
        "shout" => "highly strategic not random move"
    }
  end
  
  def filter_map_by_value(map, value) do
    #:maps.filter fn _, v -> v != value end, map
    map
    |> Enum.filter(fn {_k, v} -> v != value end)
    |> Enum.into(%{})
    
  end
 
 
 
  def avoid_self_rule(options, %{"body" => body_list, "head" => %{"x" => head_x, "y" => head_y}} = _you) do
    
   options = 
   cond do
      is_path_in_body?(%{"x" => head_x, "y" => head_y+1}, body_list)  -> Map.put(options, :up, false)
      is_path_in_body?(%{"x" => head_x, "y" => head_y-1}, body_list)  -> Map.put(options, :down, false)
      true -> options
    end
    
    IO.inspect(options, label: "avoid_self_rule - options after head_y cond")
    
    options =
    cond do
      is_path_in_body?(%{"x" => head_x+1, "y" => head_y}, body_list)  -> Map.put(options, :right, false)
      is_path_in_body?(%{"x" => head_x-1, "y" => head_y}, body_list)  -> Map.put(options, :left, false)
      true -> options
    end
    
    IO.inspect(options, label: "avoid_self_rule - options after head_x cond")
    
  end
  
  
  def is_path_in_body?(%{"x" => _x, "y" => _y} = path, body) do
     find_result = Enum.find(body, fn body_segment -> body_segment == path end)
     IO.inspect(find_result, label: "is_path_in_body?=")
     
     case find_result do
        nil -> false
        _ -> true
      end
  end
  
  
  
  def wall_rule(options, %{"body" => _body_list, "head" => %{"x" => head_x, "y" => head_y}} = you) do
    IO.inspect(you, label: "wall_rule - you")
    
    options = 
      case head_x do
          1  -> Map.put(options, :left, false)
          10 -> Map.put(options, :right, false)
          _ -> IO.inspect(options, label: "No collision left or right wall")
      end
    
    IO.inspect(options, label: "wall_rule - options after head_x case")
    
    options =
      case head_y do
          1 -> Map.put(options, :down, false)
          10 -> Map.put(options, :up, false)
          _ ->  IO.inspect(options, label: "No collision bottom or top wall")
      end
      
    IO.inspect(options, label: "wall_rule - options after head_y case")
    
  end
 
 
  
  def store_game(%{"game" => %{"id" => _game_id, 
                                "timeout" => _timeout_int} = _game_object, 
                    "turn" => _turn_int, 
                    "board" => %{ "food" => _food_list_of_coord_maps, 
                                  "height" => _height_int, 
                                  "snakes" => _snakes_list_of_maps } = _board_object, 
                    "you" => %{"body" => _you_list_of_coord_maps, 
                               "head" => _you_head_coord_map, 
                               "health" => _you_health_int, 
                               "id" => _you_id, 
                               "length" => _you_length_int, 
                               "name" => _you_name, 
                               "shout" => _you_shout } = _you_object } 
                    = game_params, 
                        game_state) do
     # Faux storage for now
     game_params
     |> IO.inspect(label: game_state)
     
  end
  
  
end
