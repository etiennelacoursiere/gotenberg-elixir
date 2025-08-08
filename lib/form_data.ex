defmodule GotenbergElixir.FormData do
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
