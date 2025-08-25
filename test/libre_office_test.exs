defmodule GotenbergElixir.LibreOfficeTest do
  use ExUnit.Case
  import Mox

  alias GotenbergElixir.LibreOffice

  setup :verify_on_exit!

  describe "convert/2" do
    test "makes POST request to LibreOffice convert endpoint" do
      docx_content = "fake-docx-content"

      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, _headers ->
        assert url =~ "/forms/libreoffice/convert"

        file_field = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        assert not is_nil(file_field)
        {_, {content, opts}} = file_field
        assert content == docx_content
        assert opts[:filename] == "document.docx"

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      assert {:ok, %{body: "fake-pdf"}} = LibreOffice.convert([{"document.docx", docx_content}])
    end

    test "handles multiple files correctly" do
      docx_content = "fake-docx"
      xlsx_content = "fake-xlsx"
      pptx_content = "fake-pptx"

      files = [
        {"document.docx", docx_content},
        {"spreadsheet.xlsx", xlsx_content},
        {"presentation.pptx", pptx_content}
      ]

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        file_1 = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        file_2 = Enum.find(form_data, fn {key, _} -> key == "file_2" end)
        file_3 = Enum.find(form_data, fn {key, _} -> key == "file_3" end)

        assert not is_nil(file_1)
        assert not is_nil(file_2)
        assert not is_nil(file_3)

        {_, {content_1, opts_1}} = file_1
        {_, {content_2, opts_2}} = file_2
        {_, {content_3, opts_3}} = file_3

        assert content_1 == docx_content
        assert opts_1[:filename] == "document.docx"

        assert content_2 == xlsx_content
        assert opts_2[:filename] == "spreadsheet.xlsx"

        assert content_3 == pptx_content
        assert opts_3[:filename] == "presentation.pptx"

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      LibreOffice.convert(files)
    end

    test "encodes options with camelCase conversion" do
      docx_content = "fake-docx"

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, _} -> key == "file_1" end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "landscape" and value == "true"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "nativePageRanges" and value == "1-10"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "exportFormFields" and value == "false"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "allowDuplicateFieldNames" and value == "true"
               end)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      LibreOffice.convert(
        [{"document.docx", docx_content}],
        landscape: true,
        native_page_ranges: "1-10",
        export_form_fields: false,
        allow_duplicate_field_names: true
      )
    end

    test "encodes compression options correctly" do
      docx_content = "fake-docx"

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, value} ->
                 key == "losslessImageCompression" and value == "true"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "quality" and value == "90"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "reduceImageResolution" and value == "false"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "maxImageResolution" and value == "300"
               end)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      LibreOffice.convert(
        [{"document.docx", docx_content}],
        lossless_image_compression: true,
        quality: 90,
        reduce_image_resolution: false,
        max_image_resolution: 300
      )
    end

    test "encodes merge option correctly" do
      docx_content = "fake-docx"

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, value} ->
                 key == "merge" and value == "true"
               end)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      LibreOffice.convert([{"document.docx", docx_content}], merge: true)
    end

    test "encodes split options correctly" do
      docx_content = "fake-docx"

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, value} ->
                 key == "splitMode" and value == "page"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "splitSpan" and value == "1-5"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "splitUnify" and value == "false"
               end)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      LibreOffice.convert(
        [{"document.docx", docx_content}],
        split_mode: "page",
        split_span: "1-5",
        split_unify: false
      )
    end

    test "encodes PDF/A and PDF/UA options correctly" do
      docx_content = "fake-docx"

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, value} ->
                 key == "pdfa" and value == "PDF/A-1b"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "pdfua" and value == "true"
               end)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      LibreOffice.convert(
        [{"document.docx", docx_content}],
        pdfa: "PDF/A-1b",
        pdfua: true
      )
    end

    test "encodes metadata as JSON" do
      docx_content = "fake-docx"
      metadata = %{"Title" => "Test Document", "Author" => "Test Author"}

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        metadata_field = Enum.find(form_data, fn {key, _} -> key == "metadata" end)
        assert not is_nil(metadata_field)
        {_, metadata_json} = metadata_field

        # Verify it's valid JSON
        assert {:ok, decoded_metadata} = JSON.decode(metadata_json)
        assert decoded_metadata["Title"] == "Test Document"
        assert decoded_metadata["Author"] == "Test Author"

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      LibreOffice.convert([{"document.docx", docx_content}], metadata: metadata)
    end

    test "encodes flatten option correctly" do
      docx_content = "fake-docx"

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, value} ->
                 key == "flatten" and value == "true"
               end)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      LibreOffice.convert([{"document.docx", docx_content}], flatten: true)
    end

    test "returns error when HTTP client fails" do
      expect(HttpClientMock, :post, fn _url, _body, _headers ->
        {:error, %{reason: :timeout, message: "Request timeout"}}
      end)

      assert {:error, %{reason: :timeout}} = LibreOffice.convert([{"doc.docx", "content"}])
    end

    test "handles empty files list" do
      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        # Should have no file fields
        file_fields = Enum.filter(form_data, fn {key, _} -> String.starts_with?(key, "file_") end)
        assert file_fields == []

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      LibreOffice.convert([])
    end
  end
end
