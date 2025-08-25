defmodule GotenbergElixirTest do
  use ExUnit.Case
  import Mox

  alias GotenbergElixir

  setup :verify_on_exit!

  describe "health/0" do
    test "makes GET request to health endpoint" do
      expect(HttpClientMock, :get, fn url, headers ->
        assert url =~ "/health"
        assert headers == []
        {:ok, %{status: 200, body: "OK", headers: %{}}}
      end)

      assert {:ok, %{status: 200, body: "OK"}} = GotenbergElixir.health()
    end
  end

  describe "version/0" do
    test "makes GET request to version endpoint" do
      expect(HttpClientMock, :get, fn url, headers ->
        assert url =~ "/version"
        assert headers == []
        {:ok, %{status: 200, body: ~s({"version": "8.0.0"}), headers: %{}}}
      end)

      assert {:ok, %{body: ~s({"version": "8.0.0"})}} = GotenbergElixir.version()
    end
  end
end
