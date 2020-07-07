defmodule SupaBattleSnake.MoveAgent do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def start_link(_initial_value) do
    start_link
  end

  def set_turn_move(turn, move) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, turn, move)
    end)
  end

  def get_turn_move(turn) do
    Agent.get(__MODULE__, fn state ->
      Map.fetch(state, turn)
    end)
  end

  def get_all_moves do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def remove_moves do
    Agent.update(__MODULE__, fn state -> state = %{} end)
  end
end
