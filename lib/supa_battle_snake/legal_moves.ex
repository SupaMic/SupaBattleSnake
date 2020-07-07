defmodule SupaBattleSnake.LegalMoves do
  alias SupaBattleSnake.GameBoardStruct, as: GameBoard
  alias SupaBattleSnake.GamePieces

  @moduledoc """
      Determine and remove illegal moves from options, only 1 move ahead, no strategy
  """

  def avoid_self(%GameBoard{} = game_data) do
    you_head = GamePieces.get_you(game_data, :head)
    body = GamePieces.get_you(game_data, :body)

    you_body = body -- [List.last(body)]
    IO.puts("SELF")

    game_data
    |> update_legal_moves(:up, you_head, you_body)
    |> update_legal_moves(:right, you_head, you_body)
    |> update_legal_moves(:down, you_head, you_body)
    |> update_legal_moves(:left, you_head, you_body)
  end

  def avoid_wall(%GameBoard{board_height: board_height} = game_data) do
    you_head = GamePieces.get_you(game_data, :head)
    IO.puts("WALL")

    game_data
    |> update_legal_moves(:up, you_head, GamePieces.wall_coords(board_height, :top))
    |> update_legal_moves(:right, you_head, GamePieces.wall_coords(board_height, :right))
    |> update_legal_moves(:down, you_head, GamePieces.wall_coords(board_height, :bottom))
    |> update_legal_moves(:left, you_head, GamePieces.wall_coords(board_height, :left))
  end

  def avoid_opponents(%GameBoard{snakes: snakes, you_id: you_id} = game_data) do
    you_head = GamePieces.get_you(game_data, :head)

    combined_opponent_coords =
      snakes
      |> Enum.filter(fn snake -> snake.id != you_id end)
      |> Enum.map(fn snake -> snake.body end)
      |> List.flatten()

    IO.puts("OPPONENTS")

    game_data
    |> update_legal_moves(:up, you_head, combined_opponent_coords)
    |> update_legal_moves(:right, you_head, combined_opponent_coords)
    |> update_legal_moves(:down, you_head, combined_opponent_coords)
    |> update_legal_moves(:left, you_head, combined_opponent_coords)
  end

  def remove_option(game_data, move) do
    Map.put(game_data, simplify_move(move), 0.0)
  end

  def update_option(game_data, move, update_value) do
    Map.put(game_data, simplify_move(move), update_value)
  end

  def update_legal_moves(game_data, move, head, check_coords) do
    not_legal =
      GamePieces.check_coord_occupied?(GamePieces.future_coords(head, move), check_coords)

    case not_legal do
      true -> remove_option(game_data, move)
      false -> game_data
    end
  end

  def update_legal_moves(game_data, move, head, check_coords, :downgrade) do
    discouraged =
      GamePieces.check_coord_occupied?(GamePieces.future_coords(head, move), check_coords)

    simple_move = simplify_move(move)

    case discouraged do
      true -> update_option(game_data, simple_move, Map.fetch!(game_data, simple_move) - 0.1)
      false -> game_data
    end
  end

  def simplify_move(move) do
    case move do
      :up_ccw -> :up
      :up_up -> :up
      :up_cw -> :up
      :right_ccw -> :right
      :right_right -> :right
      :right_cw -> :right
      :down_ccw -> :down
      :down_down -> :down
      :down_cw -> :down
      :left_ccw -> :left
      :left_left -> :left
      :left_cw -> :left
      _ -> move
    end
  end
end
