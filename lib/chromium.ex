defmodule GotenbergElixir.Chromium do
  @moduledoc """
  Provides functions to convert URLs, HTML, and Markdown files into PDFs or screenshots.
  """

  alias GotenbergElixir.Options
  alias GotenbergElixir.HttpClient
  alias GotenbergElixir.Config

  @convert_path "/forms/chromium/convert"
  @screenshot_path "/forms/chromium/screenshot"

  @type page_property_option ::
          {:single_page, boolean()}
          | {:paper_width, float()}
          | {:paper_height, float()}
          | {:margin_top, float()}
          | {:margin_bottom, float()}
          | {:margin_left, float()}
          | {:margin_right, float()}
          | {:prefer_css_page_size, boolean()}
          | {:generate_document_outline, boolean()}
          | {:generate_tagged_pdf, boolean()}
          | {:print_background, boolean()}
          | {:omit_background, boolean()}
          | {:landscape, boolean()}
          | {:scale, float()}
          | {:native_page_ranges, String.t()}

  @type screenshot_option ::
          {:width, non_neg_integer()}
          | {:height, non_neg_integer()}
          | {:clip, boolean()}
          | {:format, String.t()}
          | {:quality, non_neg_integer()}
          | {:omit_background, boolean()}
          | {:optimize_for_speed, boolean()}
          | wait_option()
          | media_type_option()
          | cookie_option()
          | custom_http_header_option()
          | invalid_http_status_codes_option()
          | console_exception_option()
          | performance_mode_option()

  @type files :: list({String.t(), binary()})

  @type wait_option ::
          {:wait_delay, String.t()}
          | {:wait_for_expression, String.t()}

  @type media_type_option :: {:emulate_media_type, String.t()}

  @type cookie :: %{
          name: String.t(),
          value: String.t(),
          domain: String.t(),
          path: String.t() | nil,
          secure: boolean() | nil,
          http_only: boolean() | nil,
          same_site: String.t() | nil
        }

  @type cookie_option :: {:cookies, list(cookie())}

  @type custom_http_header_option :: {:user_agent, String.t()} | {:extra_http_headers, map()}

  @type invalid_http_status_codes_option ::
          {:fail_on_http_status_codes, list(non_neg_integer())}
          | {:fail_on_resource_http_status_codes, list(non_neg_integer())}

  @type network_error_option :: {:fail_on_resource_loading_failed, boolean()}

  @type console_exception_option :: {:fail_on_console_exceptions, boolean()}

  @type performance_mode_option :: {:skip_network_idle_event, boolean()}

  @type split_option ::
          {:split_mode, String.t()}
          | {:split_span, String.t()}
          | {:split_unify, boolean()}

  @type pdfa_pdfua_option :: {:pdfa, String.t()} | {:pdfua, boolean()}

  @type metadata_option :: {:metadata, map()}

  @type flatten_option :: {:flatten, boolean()}

  @type pdf_option ::
          page_property_option()
          | wait_option()
          | media_type_option()
          | cookie_option()
          | custom_http_header_option()
          | invalid_http_status_codes_option()
          | network_error_option()
          | console_exception_option()
          | performance_mode_option()
          | split_option()
          | pdfa_pdfua_option()
          | metadata_option()
          | flatten_option()

  @doc """
    Converts a URL into a PDF using Chromium.

    ## Parameters
    - `url`: The URL to convert.
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """

  @spec url_into_pdf(String.t(), [pdf_option()]) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}

  def url_into_pdf(url, options \\ []) when is_binary(url) and is_list(options) do
    url_into(@convert_path, url, options)
  end

  @doc """
    Converts a URL into a screenshot using Chromium.

    ## Parameters
    - `url`: The URL to convert.
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """

  @spec url_into_screenshot(String.t(), [screenshot_option()]) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}

  def url_into_screenshot(url, options \\ []) when is_binary(url) and is_list(options) do
    url_into(@screenshot_path, url, options)
  end

  defp url_into(path, url, options) do
    endpoint = Config.base_url() <> path <> "/url"
    options = [url: url] ++ options
    form_data = Options.encode_options(options)

    HttpClient.post(endpoint, {:multipart, form_data})
  end

  @doc """
    Converts HTML file content into a PDF using Chromium.

    ## Parameters
    - `html`: The HTML content as a binary string.
    - `additional_files`: A list of additional files (images, CSS, fonts) as {filename, file}
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """

  @spec html_file_into_pdf(binary, files(), [pdf_option()]) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}

  def html_file_into_pdf(html, additional_files \\ [], options \\ [])
      when is_binary(html) and is_list(additional_files) and is_list(options) do
    html_file_into(@convert_path, html, additional_files, options)
  end

  @doc """
    Converts HTML file content into a screenshot using Chromium.

    ## Parameters
    - `html`: The HTML content as a binary string.
    - `additional_files`: A list of additional files (images, CSS, fonts) as {filename, file}
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """

  @spec html_file_into_screenshot(binary, files(), [screenshot_option()]) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}

  def html_file_into_screenshot(html, additional_files \\ [], options \\ [])
      when is_binary(html) and is_list(additional_files) and is_list(options) do
    html_file_into(@screenshot_path, html, additional_files, options)
  end

  defp html_file_into(path, html, additional_files, options)
       when is_binary(html) and is_list(additional_files) and is_list(options) do
    endpoint = Config.base_url() <> path <> "/html"

    files = [{"index.html", html}] ++ additional_files
    form_data = Options.encode_files_options(files) ++ Options.encode_options(options)

    HttpClient.post(endpoint, {:multipart, form_data})
  end

  @doc """
    Converts Markdown files into a PDF using Chromium.

    ## Parameters
    - `index_html`: The HTML template content that wraps the markdown (uses `{{ toHTML "filename.md" }}` syntax).
    - `markdown_files`: A list of markdown files as {filename, file}
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """

  @spec markdown_files_into_pdf(String.t(), files(), [pdf_option()]) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}

  def markdown_files_into_pdf(index_html, markdown_files, options \\ [])
      when is_binary(index_html) and is_list(markdown_files) and is_list(options) do
    markdown_files_into(@convert_path, index_html, markdown_files, options)
  end

  @doc """
    Converts Markdown files into a screenshot using Chromium.

    ## Parameters
    - `index_html`: The HTML template content that wraps the markdown (uses `{{ toHTML "filename.md" }}` syntax).
    - `markdown_files`: A list of markdown files as {filename, file}
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """

  @spec markdown_files_into_screenshot(String.t(), files(), [screenshot_option()]) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}

  def markdown_files_into_screenshot(index_html, markdown_files, options \\ [])
      when is_binary(index_html) and is_list(markdown_files) and is_list(options) do
    markdown_files_into(@screenshot_path, index_html, markdown_files, options)
  end

  defp markdown_files_into(path, index_html, markdown_files, options)
       when is_binary(index_html) and is_list(markdown_files) and is_list(options) do
    endpoint = Config.base_url() <> path <> "/markdown"
    files = [{"index.html", index_html}] ++ markdown_files
    form_data = Options.encode_files_options(files) ++ Options.encode_options(options)

    HttpClient.post(endpoint, {:multipart, form_data})
  end
end
