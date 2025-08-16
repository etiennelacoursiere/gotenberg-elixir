defmodule GotenbergElixir.PDF do
  @moduledoc """
  """
  alias GotenbergElixir.HttpClient
  alias GotenbergElixir.Options
  alias GotenbergElixir.Config

  @pdf_path "/forms/pdfengines"

  @type files :: list({String.t(), binary()})
  @type pdfa_pdfua_option :: {:pdfa, String.t()} | {:pdfua, boolean()}
  @type metadata_option :: {:metadata, map()}
  @type flatten_option :: {:flatten, boolean()}

  @type convert_option :: pdfa_pdfua_option()
  @type write_metadata_option :: metadata_option()
  @type merge_option :: pdfa_pdfua_option() | metadata_option() | flatten_option()
  @type split_option ::
          {:split_mode, String.t()}
          | {:split_span, String.t()}
          | {:split_unify, boolean()}
          | pdfa_pdfua_option()
          | metadata_option()
          | flatten_option()

  @doc """
    Transforms one or more PDF files into the requested PDF/A format and/or PDF/UA.

    ## Parameters
    - `files`: A list of tuples containing the file name and its binary content.
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """

  @spec convert(files :: files(), options :: [convert_option]) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}
  def convert(files, options \\ []) do
    endpoint = Config.base_url() <> @pdf_path <> "/convert"
    files = Options.encode_files_options(files)
    options = Options.encode_options(options)
    form_data = files ++ options

    HttpClient.post(endpoint, {:multipart, form_data})
  end

  @doc """
    Returns metadata for one or more PDF files.

    ## Parameters
    - `files`: A list of file paths or URLs.
  """

  @spec read_pdf_metadata(files :: files()) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}
  def read_pdf_metadata(files) do
    endpoint = Config.base_url() <> @pdf_path <> "/metadata/read"
    files = Options.encode_files_options(files)

    HttpClient.post(endpoint, {:multipart, files})
  end

  @doc """
    Writes metadata for one or more PDF files.

    ## Parameters
    - `files`: A list of file paths or URLs.
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """

  @spec write_pdf_metadata(files :: files(), [write_metadata_option()]) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}

  def write_pdf_metadata(files, options \\ []) do
    endpoint = Config.base_url() <> @pdf_path <> "/metadata/write"
    files = Options.encode_files_options(files)
    options = Options.encode_options(options)
    form_data = files ++ options

    HttpClient.post(endpoint, {:multipart, form_data})
  end

  @doc """
    Merges one or more PDF files.

    ## Parameters
    - `files`: A list of file paths or URLs.
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """
  @spec merge_pdf(files :: files(), [merge_option()]) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}

  def merge_pdf(files, options \\ []) do
    endpoint = Config.base_url() <> @pdf_path <> "/merge"
    files = Options.encode_files_options(files)
    options = Options.encode_options(options)
    form_data = files ++ options

    HttpClient.post(endpoint, {:multipart, form_data})
  end

  @doc """
    Split one or more PDF files.

    ## Parameters
    - `files`: A list of file paths or URLs.
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """

  @spec split_pdf(files :: files(), [split_option()]) ::
          {:ok, HttpClient.Behaviour.response()}
          | {:error, HttpClient.Behaviour.error()}

  def split_pdf(files, options \\ []) do
    endpoint = Config.base_url() <> @pdf_path <> "/split"
    files = Options.encode_files_options(files)
    options = Options.encode_options(options)
    form_data = files ++ options

    HttpClient.post(endpoint, {:multipart, form_data})
  end

  def flatten_pdf(files) do
    endpoint = Config.base_url() <> @pdf_path <> "/flatten"
    files = Options.encode_files_options(files)

    HttpClient.post(endpoint, {:multipart, files})
  end
end
