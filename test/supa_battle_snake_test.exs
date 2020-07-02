defmodule SupaBattleSnakeTest do
  use ExUnit.Case
  doctest SupaBattleSnake

  
  setup do 
    game_data = %SupaBattleSnake.GameBoard{
      board_food: [%{"x" => 3, "y" => 10}],
      board_height: 11,
      down: 0.5,
      game_id: "6689cda7-d7bf-43bc-8c47-b6109861ba2a",
      left: 0.5,
      right: 0.5,
      route_state: :move,
      snakes: [
        %SupaBattleSnake.Snake{
          body: [
            %{"x" => 1, "y" => 7},
            %{"x" => 1, "y" => 6},
            %{"x" => 1, "y" => 5},
            %{"x" => 1, "y" => 4},
            %{"x" => 1, "y" => 3},
            %{"x" => 1, "y" => 2},
            %{"x" => 2, "y" => 2},
            %{"x" => 2, "y" => 1},
            %{"x" => 1, "y" => 1},
            %{"x" => 0, "y" => 1},
            %{"x" => 0, "y" => 2},
            %{"x" => 0, "y" => 3},
            %{"x" => 0, "y" => 4},
            %{"x" => 0, "y" => 5},
            %{"x" => 0, "y" => 6},
            %{"x" => 0, "y" => 7},
            %{"x" => 0, "y" => 8}
          ],
          head: %{"x" => 1, "y" => 7},
          health: 95,
          id: "gs_bfcBVmHxKtj6WhRSBDbJPvX7",
          length: 17,
          name: "NopeRope",
          shout: "",
          you: false
        },
        %SupaBattleSnake.Snake{
          body: [
            %{"x" => 6, "y" => 10},
            %{"x" => 7, "y" => 10},
            %{"x" => 8, "y" => 10},
            %{"x" => 9, "y" => 10},
            %{"x" => 10, "y" => 10},
            %{"x" => 10, "y" => 10}
          ],
          head: %{"x" => 6, "y" => 10},
          health: 100,
          id: "gs_yYGTpgSXSyTGx74cqwGtmMw3",
          length: 6,
          name: "Snake 1a",
          shout: "6% ready",
          you: false
        },
        %SupaBattleSnake.Snake{
          body: [
            %{"x" => 5, "y" => 5},
            %{"x" => 6, "y" => 5},
            %{"x" => 6, "y" => 6},
            %{"x" => 6, "y" => 7},
            %{"x" => 7, "y" => 7},
            %{"x" => 7, "y" => 6},
            %{"x" => 7, "y" => 5},
            %{"x" => 8, "y" => 5}
          ],
          head: %{"x" => 5, "y" => 5},
          health: 93,
          id: "gs_hDf3H7F9SgyfQjKFRYGkbJRH",
          length: 8,
          name: "Heuristic Harry",
          shout: "moving",
          you: true
        }
      ],
      timeout: 500,
      turn: 72,
      up: 0.5,
      you_id: "gs_hDf3H7F9SgyfQjKFRYGkbJRH"
    }
    
    {:ok, game_data: game_data}
  end
  
  test "Check coords: you head", context do
    assert SupaBattleSnake.get_you(context[:game_data], :head) ==  %{"x" => 5, "y" => 5}
  end
  
  describe "Game Snake Initializations" do 
  
    test "Confirm Attributes" do
      assert SupaBattleSnake.get_snake ==    %{ "apiversion" => "1", 
                                                "author" => "supamic", 
                                                "color" => "#ff9900",
                                                "head" => "pixel",
                                                "tail" => "default" }
    end
  
  end
  
end
