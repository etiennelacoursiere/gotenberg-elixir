defmodule GotenbergElixir.Chromium do
  alias GotenbergElixir.HttpClient

  @convert_path "/forms/chromium/convert"

  @type options :: [
          single_page: boolean(),
          paper_width: float(),
          paper_height: float(),
          margin_top: float(),
          margin_bottom: float(),
          margin_left: float(),
          margin_right: float(),
          prefer_css_page_size: boolean(),
          generate_document_outline: boolean(),
          generate_tagged_pdf: boolean(),
          print_background: boolean(),
          omit_background: boolean(),
          landscape: boolean(),
          scale: float(),
          native_page_range: String.t()
        ]

  @type files :: list({String.t(), binary()})

  @doc """
    Converts a URL into a PDF using Chromium.

    ## Parameters
    - `url`: The URL to convert.
    - `options`: Optional parameters for the conversion.

    ## Options
    Options are passed as a keyword list.

    For example:

    GotenbergElixir.Chromium.url_into_pdf("https://example.com", [paper_width: 8.5, paper_height: 11])

    For a list of all available options, refer to the official Gotenberg documentation.

    ## Returns
    - `{:ok, response}` if the conversion is successful.
    - `{:error, error}` if the conversion fails.
  """

  @spec url_into_pdf(String.t(), options()) ::
          {:ok, GotenbergElixir.HttpClient.Behaviour.response()}
          | {:error, GotenbergElixir.HttpClient.Behaviour.error()}

  def url_into_pdf(url, options \\ []) when is_binary(url) and is_list(options) do
    endpoint = GotenbergElixir.Config.base_url() <> @convert_path <> "/url"
    form_data = [{"url", url}]

    case HttpClient.post(endpoint, {:multipart, form_data}) do
      {:ok, %{status: 200} = response} ->
        {:ok, response}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
    Converts HTML file content into a PDF using Chromium.

    ## Parameters
    - `html`: The HTML content as a binary string.
    - `additional_files`: A list of additional files (images, CSS, fonts) as {filename, content}

    ## Returns
    - `{:ok, response}` if the conversion is successful.
    - `{:error, error}` if the conversion fails.
  """

  @spec html_file_into_pdf(binary, files(), options()) ::
          {:ok, GotenbergElixir.HttpClient.Behaviour.response()}
          | {:error, GotenbergElixir.HttpClient.Behaviour.error()}

  def html_file_into_pdf(html, additional_files \\ [], options \\ [])
      when is_binary(html) and is_list(additional_files) and is_list(options) do
    endpoint = GotenbergElixir.Config.base_url() <> @convert_path <> "/html"

    index_form_data = [index: {html, filename: "index.html"}]
    additional_files_form_data = GotenbergElixir.FormData.reduce_files(additional_files)
    form_data = Keyword.merge(index_form_data, additional_files_form_data)

    case HttpClient.post(endpoint, {:multipart, form_data}) do
      {:ok, %{status: 200} = response} ->
        {:ok, response}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
    Converts Markdown files into a PDF using Chromium.

    ## Parameters
    - `index_html`: The HTML template content that wraps the markdown (uses `{{ toHTML "filename.md" }}` syntax).
    - `markdown_files`: A list of tuples containing the filename and content of each markdown file. [{"filename.md", file}]

    ## Returns
    - `{:ok, response}` if the conversion is successful.
    - `{:error, error}` if the conversion fails.
  """

  @spec markdown_files_into_pdf(String.t(), files(), options()) ::
          {:ok, GotenbergElixir.HttpClient.Behaviour.response()}
          | {:error, GotenbergElixir.HttpClient.Behaviour.error()}

  def markdown_files_into_pdf(index_html, markdown_files, options \\ [])
      when is_binary(index_html) and is_list(markdown_files) and is_list(options) do
    endpoint = GotenbergElixir.Config.base_url() <> @convert_path <> "/markdown"

    index_form_data = [index: {index_html, filename: "index.html"}]
    markdown_files_form_data = GotenbergElixir.FormData.reduce_files(markdown_files)
    form_data = Keyword.merge(index_form_data, markdown_files_form_data)

    case HttpClient.post(endpoint, {:multipart, form_data}) do
      {:ok, %{status: 200} = response} ->
        {:ok, response}

      {:error, error} ->
        {:error, error}
    end
  end
end
