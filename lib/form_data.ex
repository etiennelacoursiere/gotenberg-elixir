defmodule GotenbergElixir.FormData do
  @doc """
  Encodes a list of options to the format required by Gotenberg.
  """

  def encode_options(options) when is_list(options) do
    Enum.reduce(options, [], &[encode_option(&1) | &2])
  end

  defp encode_option({name, value}) do
    name = GotenbergElixir.Casing.camelize(name)
    value = to_string(value)
    {name, value}
  end

  @doc """
  Converts a list of files as {filename, file_content} into a proper keyword list that can be used in form data.
  """

  def reduce_files(files) do
    files
    |> Enum.with_index(1)
    |> Enum.reduce(Keyword.new(), fn {{filename, content}, index}, acc ->
      Keyword.put(acc, String.to_atom("file_#{index}"), {content, filename: filename})
    end)
  end
end
