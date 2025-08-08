defmodule GotenbergElixir.FormDataTest do
  use ExUnit.Case
  alias GotenbergElixir.FormData

  describe "reduce_files/1" do
    test "converts single file tuple to keyword list" do
      files = [{"index.css", "body { color: red; }"}]
      result = FormData.reduce_files(files)

      assert result == [file_1: {"body { color: red; }", filename: "index.css"}]
    end

    test "converts multiple file tuples to keyword list with sequential keys" do
      files = [
        {"style.css", "body { margin: 0; }"},
        {"logo.png", <<137, 80, 78, 71>>},
        {"script.js", "console.log('hello');"}
      ]

      result = FormData.reduce_files(files)

      expected = [
        file_1: {"body { margin: 0; }", filename: "style.css"},
        file_2: {<<137, 80, 78, 71>>, filename: "logo.png"},
        file_3: {"console.log('hello');", filename: "script.js"}
      ]

      assert Keyword.get(result, :file_1) == expected[:file_1]
      assert Keyword.get(result, :file_2) == expected[:file_2]
      assert Keyword.get(result, :file_3) == expected[:file_3]
    end
  end
end
