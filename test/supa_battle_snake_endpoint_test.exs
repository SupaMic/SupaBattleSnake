defmodule SupaBattleSnake.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts SupaBattleSnake.Endpoint.init([])

  @tag :endpoints
  describe "endpoints" do
    @tag :endpoints
    test "it returns pong" do
      # Create a test connection
      conn = conn(:get, "/ping")

      # Invoke the plug
      conn = SupaBattleSnake.Endpoint.call(conn, @opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "pong!"
    end

    @tag :endpoints
    test "it returns 200 with a valid payload" do
      # Create a test connection
      conn = conn(:post, "/start", %{game: "", turn: 0, board: "", you: ""})

      # Invoke the plug
      conn = SupaBattleSnake.Endpoint.call(conn, @opts)

      # Assert the response
      assert conn.status == 200
    end

    @tag :endpoints
    test "it returns 422 with an invalid payload" do
      # Create a test connection
      conn = conn(:post, "/start", %{})

      # Invoke the plug
      conn = SupaBattleSnake.Endpoint.call(conn, @opts)

      # Assert the response
      assert conn.status == 422
    end

    @tag :endpoints
    test "it returns 404 when no route matches" do
      # Create a test connection
      conn = conn(:get, "/fail")

      # Invoke the plug
      conn = SupaBattleSnake.Endpoint.call(conn, @opts)

      # Assert the response
      assert conn.status == 404
    end
  end
end
