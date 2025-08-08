defmodule GotenbergElixirTest do
  use ExUnit.Case
  doctest GotenbergElixir

  setup do
    Application.put_env(:gotenberg_elixir, :base_url, "http://localhost:3092")
  end

  test "health check" do
    assert {:ok, %{status: 200}} = GotenbergElixir.health()
  end

  test "version" do
    assert {:ok, %{status: 200}} = GotenbergElixir.version()
  end
end
