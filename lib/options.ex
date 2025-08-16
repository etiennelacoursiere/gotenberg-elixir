defmodule GotenbergElixir.Options do
  @doc """
  Encodes a list of options to the format required by Gotenberg.
  """

  def encode_options(options) when is_list(options) do
    Enum.reduce(options, [], &[encode_option(&1) | &2])
  end

  defp encode_option({:cookies, value}) when is_list(value) do
    value =
      Enum.map(value, fn cookie ->
        cookie
        |> Enum.map(fn {k, v} -> {GotenbergElixir.Casing.camelize(k), v} end)
        |> Enum.into(%{})
        |> JSON.encode!()
      end)

    {"cookies", value}
  end

  defp encode_option({name, value}) when is_list(value) do
    {GotenbergElixir.Casing.camelize(name), JSON.encode!(value)}
  end

  defp encode_option({name, value}) when is_map(value) do
    name = GotenbergElixir.Casing.camelize(name)
    value = JSON.encode!(value)
    {name, value}
  end

  defp encode_option({name, value}) do
    name = GotenbergElixir.Casing.camelize(name)
    value = to_string(value)
    {name, value}
  end

  @doc """
  Converts a list of files as {filename, file_content} into a proper keyword list that can be used in form data.
  """
  def encode_files_options(files) do
    files
    |> Enum.with_index(1)
    |> Enum.reduce([], fn {{filename, content}, index}, acc ->
      [{"file_#{index}", {content, filename: filename}} | acc]
    end)
  end
end
