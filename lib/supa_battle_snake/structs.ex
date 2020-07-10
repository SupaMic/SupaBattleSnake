defmodule SupaBattleSnake.GameBoardStruct do
  @moduledoc """
    We use two structs GameBoard and Snake to keep track of game state at each move request.  The Snake struct is used to populate the 
    the list of snakes in the Gameboard struct.
    """
  defstruct game_id: "",
            timeout: 500,
            turn: 0,
            board_food: [],
            board_height: 0,
            you_id: "",
            snakes: [],
            route_state: nil,
            up: 0.5,
            right: 0.5,
            down: 0.5,
            left: 0.5
end

defmodule SupaBattleSnake.SnakeStruct do
  @moduledoc """
    We use two structs GameBoard and Snake to keep track of game state at each move request.  The Snake struct is used to populate the 
    the list of snakes in the Gameboard struct.
    """
  defstruct body: [],
            head: %{x: 0, y: 0},
            health: 100,
            id: "",
            length: 3,
            name: "",
            shout: "",
            you: false
end
