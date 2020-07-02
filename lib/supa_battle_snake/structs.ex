defmodule SupaBattleSnake.GameBoard do
  defstruct game_id: "", timeout: 500, turn: 0, board_food: [], board_height: 0, you_id: "", snakes: [], route_state: nil, up: 0.5, right: 0.5, down: 0.5, left: 0.5
end


defmodule SupaBattleSnake.Snake do
  defstruct body: [], head: %{x: 0, y: 0}, health: 100, id: "", length: 3, name: "", shout: "", you: false
end
