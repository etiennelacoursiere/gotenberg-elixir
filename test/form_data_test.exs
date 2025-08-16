defmodule GotenbergElixir.OptionsTest do
  use ExUnit.Case
  alias GotenbergElixir.Options

  describe "encode_options/1" do
    test "encodes empty list" do
      assert Options.encode_options([]) == []
    end

    test "encodes single option with atom key" do
      options = [paper_width: "8.5"]
      result = Options.encode_options(options)

      assert result == [{"paperWidth", "8.5"}]
    end

    test "encodes single option with string key" do
      options = [{"paper_height", 11}]
      result = Options.encode_options(options)

      assert result == [{"paperHeight", "11"}]
    end

    test "encodes multiple options with snake_case conversion" do
      options = [
        page_ranges: "1-5",
        print_background: true,
        landscape: false,
        margin_top: "0.5in"
      ]

      result = Options.encode_options(options)

      expected = [
        {"marginTop", "0.5in"},
        {"landscape", "false"},
        {"printBackground", "true"},
        {"pageRanges", "1-5"}
      ]

      assert length(result) == length(expected)
      assert Enum.all?(expected, &(&1 in result))
    end

    test "converts various value types to strings" do
      options = [
        string_value: "test",
        integer_value: 42,
        float_value: 3.14,
        boolean_true: true,
        boolean_false: false,
        atom_value: :some_atom
      ]

      result = Options.encode_options(options)

      expected = [
        {"atomValue", "some_atom"},
        {"booleanFalse", "false"},
        {"booleanTrue", "true"},
        {"floatValue", "3.14"},
        {"integerValue", "42"},
        {"stringValue", "test"}
      ]

      assert length(result) == length(expected)
      assert Enum.all?(expected, &(&1 in result))
    end
  end

  describe "reduce_files/1" do
    test "converts single file tuple to keyword list" do
      files = [{"index.css", "body { color: red; }"}]
      result = Options.encode_files_options(files)

      assert result == [{"file_1", {"body { color: red; }", filename: "index.css"}}]
    end

    test "converts multiple file tuples to keyword list with sequential keys" do
      files = [
        {"style.css", "body { margin: 0; }"},
        {"logo.png", <<137, 80, 78, 71>>},
        {"script.js", "console.log('hello');"}
      ]

      result = Options.encode_files_options(files)

      expected = [
        {"file_1", {"body { margin: 0; }", filename: "style.css"}},
        {"file_2", {<<137, 80, 78, 71>>, filename: "logo.png"}},
        {"file_3", {"console.log('hello');", filename: "script.js"}}
      ]

      assert length(result) == length(expected)
      assert Enum.all?(expected, &(&1 in result))
    end
  end
end
