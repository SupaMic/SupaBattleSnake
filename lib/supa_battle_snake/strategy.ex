defmodule SupaBattleSnake.Strategy do
  @moduledoc """
  Boost or downgrade options using GameBoard state in relation to you head
  """

  alias SupaBattleSnake.GameBoardStruct, as: GameBoard
  alias SupaBattleSnake.{GamePieces, LegalMoves}

  def choose_adjacent_food(%GameBoard{board_food: board_food} = game_data) do
    you_head = GamePieces.get_you(game_data, :head)

    game_data
    |> update_beneficial_moves(:up, you_head, board_food)
    |> update_beneficial_moves(:right, you_head, board_food)
    |> update_beneficial_moves(:down, you_head, board_food)
    |> update_beneficial_moves(:left, you_head, board_food)
  end

  def update_beneficial_moves(game_data, move, head, check_coords) do
    beneficial =
      GamePieces.check_coord_occupied?(GamePieces.future_coords(head, move), check_coords)

    case beneficial do
      true -> boost_option(game_data, move)
      false -> game_data
    end
  end

  def boost_option(%GameBoard{up: up, right: right, down: down, left: left} = game_data, move) do
    game_data
    |> Map.put(move, Map.fetch!(game_data, move) + 0.09)
  end

  def avoid_head_to_head(%GameBoard{snakes: snakes} = game_data) do
    you_head = GamePieces.get_you(game_data, :head)

    combined_opponent_coords = Enum.map(snakes, fn snake -> snake.head end) |> List.flatten()
    IO.puts("HEADTOHEAD")

    game_data
    |> LegalMoves.update_legal_moves(:up_ccw, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:up_up, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:up_cw, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:right_ccw, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:right_right, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:right_cw, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:down_ccw, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:down_down, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:down_cw, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:left_ccw, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:left_left, you_head, combined_opponent_coords, :downgrade)
    |> LegalMoves.update_legal_moves(:left_cw, you_head, combined_opponent_coords, :downgrade)
  end
end
