defmodule SupaBattleSnake.GamePieces do 

    @moduledoc """
        Easy access to all the game pieces
    """
    alias SupaBattleSnake.GameBoardStruct, as: GameBoard    
    
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
  
  
  def wall_coords(board_height, location) do
    case location do
      :top -> Enum.map(-1..board_height, fn x -> %{"x" => x, "y" => 11 } end)
      :right -> Enum.map(-1..board_height, fn y -> %{"x" => 11, "y" => y } end)
      :bottom -> Enum.map(-1..board_height, fn x -> %{"x" => x, "y" => -1 } end)
      :left -> Enum.map(-1..board_height, fn y -> %{"x" => -1, "y" => y } end) 
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
  

end