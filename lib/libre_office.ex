defmodule GotenbergElixir.LibreOffice do
  @moduledoc """
  Provides functions to convert documents into PDF using Gotenberg's LibreOffice service.
  """

  alias GotenbergElixir.HttpClient
  alias GotenbergElixir.Options
  alias GotenbergElixir.Config

  @convert_path "/forms/libreoffice/convert"

  @type page_property_option ::
          {:password, String.t()}
          | {:landscape, boolean()}
          | {:native_page_ranges, String.t()}
          | {:update_indexes, boolean()}
          | {:export_form_fields, boolean()}
          | {:allow_duplicate_field_names, boolean()}
          | {:export_bookmarks, boolean()}
          | {:export_bookmarks_to_pdf_destination, boolean()}
          | {:export_placeholders, boolean()}
          | {:export_notes, boolean()}
          | {:export_notes_pages, boolean()}
          | {:export_only_notes_pages, boolean()}
          | {:export__notes_in_margin, boolean()}
          | {:convert_ooo_target_to_pdf, boolean()}
          | {:export_links_relative_fsys, boolean()}
          | {:export_hidden_slides, boolean()}
          | {:skip_empty_pages, boolean()}
          | {:add_original_document_as_stream, boolean()}
          | {:single_page_sheets, boolean()}

  @type compress_option ::
          {:lossless_image_compression, boolean()}
          | {:quality, integer()}
          | {:reduce_image_resolution, boolean()}
          | {:max_image_resolution, integer()}

  @type merge_option :: {:merge, boolean()}

  @type split_option ::
          {:split_mode, String.t()}
          | {:split_span, String.t()}
          | {:split_unify, boolean()}

  @type pdfa_pdfua_option :: {:pdfa, String.t()} | {:pdfua, boolean()}

  @type metadata_option :: {:metadata, map()}

  @type flatten_option :: {:flatten, boolean()}

  @type option ::
          page_property_option
          | compress_option
          | merge_option
          | split_option
          | pdfa_pdfua_option
          | metadata_option
          | flatten_option

  @type files :: list({String.t(), binary()})

  @doc """
    Converts one or more LibreOffice document into a PDF file.

    ## Parameters
    - `files`: A list of tuples containing the filename and content of each LibreOffice document. [{"filename.odt", file}]
    - `options`: Optional parameters passed as a keyword list.

    ## Options
    For a list of all available options, refer to the official Gotenberg documentation.
  """

  @spec document_into_pdf(files :: files(), options :: [option()]) ::
          {:ok, HttpClient.response()} | {:error, HttpClient.error()}

  def document_into_pdf(files, options \\ []) do
    endpoint = Config.base_url() <> @convert_path
    files = Options.encode_files_options(files)
    options = Options.encode_options(options)
    form_data = files ++ options

    HttpClient.post(endpoint, {:multipart, form_data})
  end
end
