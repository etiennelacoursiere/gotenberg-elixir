defmodule GotenbergElixir.PdfTest do
  use ExUnit.Case
  import Mox

  alias GotenbergElixir.Pdf

  setup :verify_on_exit!

  describe "convert/2" do
    test "makes POST request to PDF convert endpoint" do
      pdf_content = "fake-pdf-content"

      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, _headers ->
        assert url =~ "/forms/pdfengines/convert"

        file_field = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        assert not is_nil(file_field)
        {_, {content, opts}} = file_field
        assert content == pdf_content
        assert opts[:filename] == "document.pdf"

        {:ok, %{status: 200, body: "fake-converted-pdf", headers: %{}}}
      end)

      assert {:ok, %{body: "fake-converted-pdf"}} = Pdf.convert([{"document.pdf", pdf_content}])
    end

    test "encodes PDF/A and PDF/UA options correctly" do
      pdf_content = "fake-pdf"

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, _} -> key == "file_1" end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "pdfa" and value == "PDF/A-2b"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "pdfua" and value == "true"
               end)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Pdf.convert([{"document.pdf", pdf_content}], pdfa: "PDF/A-2b", pdfua: true)
    end

    test "handles multiple PDF files" do
      pdf1_content = "fake-pdf-1"
      pdf2_content = "fake-pdf-2"

      files = [
        {"doc1.pdf", pdf1_content},
        {"doc2.pdf", pdf2_content}
      ]

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        file_1 = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        file_2 = Enum.find(form_data, fn {key, _} -> key == "file_2" end)

        assert not is_nil(file_1)
        assert not is_nil(file_2)

        {_, {content_1, opts_1}} = file_1
        {_, {content_2, opts_2}} = file_2

        assert content_1 == pdf1_content
        assert opts_1[:filename] == "doc1.pdf"

        assert content_2 == pdf2_content
        assert opts_2[:filename] == "doc2.pdf"

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Pdf.convert(files)
    end
  end

  describe "read_pdf_metadata/1" do
    test "makes POST request to metadata read endpoint" do
      pdf_content = "fake-pdf-content"

      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, _headers ->
        assert url =~ "/forms/pdfengines/metadata/read"

        file_field = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        assert not is_nil(file_field)
        {_, {content, opts}} = file_field
        assert content == pdf_content
        assert opts[:filename] == "document.pdf"

        {:ok, %{status: 200, body: ~s({"Title": "Test PDF"}), headers: %{}}}
      end)

      assert {:ok, %{body: ~s({"Title": "Test PDF"})}} =
               Pdf.read_pdf_metadata([{"document.pdf", pdf_content}])
    end

    test "handles multiple PDF files for metadata reading" do
      pdf1_content = "fake-pdf-1"
      pdf2_content = "fake-pdf-2"

      files = [
        {"doc1.pdf", pdf1_content},
        {"doc2.pdf", pdf2_content}
      ]

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        file_1 = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        file_2 = Enum.find(form_data, fn {key, _} -> key == "file_2" end)

        assert not is_nil(file_1)
        assert not is_nil(file_2)

        {:ok, %{status: 200, body: "fake-metadata", headers: %{}}}
      end)

      Pdf.read_pdf_metadata(files)
    end
  end

  describe "write_pdf_metadata/2" do
    test "makes POST request to metadata write endpoint" do
      pdf_content = "fake-pdf-content"
      metadata = %{"Title" => "Updated Title", "Author" => "Test Author"}

      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, _headers ->
        assert url =~ "/forms/pdfengines/metadata/write"

        file_field = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        assert not is_nil(file_field)
        {_, {content, opts}} = file_field
        assert content == pdf_content
        assert opts[:filename] == "document.pdf"

        metadata_field = Enum.find(form_data, fn {key, _} -> key == "metadata" end)
        assert not is_nil(metadata_field)
        {_, metadata_json} = metadata_field

        assert {:ok, decoded_metadata} = JSON.decode(metadata_json)
        assert decoded_metadata["Title"] == "Updated Title"

        {:ok, %{status: 200, body: "fake-pdf-with-metadata", headers: %{}}}
      end)

      Pdf.write_pdf_metadata([{"document.pdf", pdf_content}], metadata: metadata)
    end

    test "works without metadata options" do
      pdf_content = "fake-pdf-content"

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        file_field = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        assert not is_nil(file_field)

        metadata_field = Enum.find(form_data, fn {key, _} -> key == "metadata" end)
        assert is_nil(metadata_field)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Pdf.write_pdf_metadata([{"document.pdf", pdf_content}])
    end
  end

  describe "merge_pdf/2" do
    test "makes POST request to merge endpoint" do
      pdf1_content = "fake-pdf-1"
      pdf2_content = "fake-pdf-2"

      files = [
        {"doc1.pdf", pdf1_content},
        {"doc2.pdf", pdf2_content}
      ]

      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, _headers ->
        assert url =~ "/forms/pdfengines/merge"

        file_1 = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        file_2 = Enum.find(form_data, fn {key, _} -> key == "file_2" end)

        assert not is_nil(file_1)
        assert not is_nil(file_2)

        {:ok, %{status: 200, body: "fake-merged-pdf", headers: %{}}}
      end)

      assert {:ok, %{body: "fake-merged-pdf"}} = Pdf.merge_pdf(files)
    end

    test "encodes merge options correctly" do
      pdf_content = "fake-pdf"
      metadata = %{"Title" => "Merged Document"}

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, value} ->
                 key == "pdfa" and value == "PDF/A-1b"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "pdfua" and value == "true"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "flatten" and value == "true"
               end)

        # Verify metadata is JSON
        metadata_field = Enum.find(form_data, fn {key, _} -> key == "metadata" end)
        assert not is_nil(metadata_field)
        {_, metadata_json} = metadata_field
        assert {:ok, decoded} = JSON.decode(metadata_json)
        assert decoded["Title"] == "Merged Document"

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Pdf.merge_pdf(
        [{"doc.pdf", pdf_content}],
        pdfa: "PDF/A-1b",
        pdfua: true,
        flatten: true,
        metadata: metadata
      )
    end
  end

  describe "split_pdf/2" do
    test "makes POST request to split endpoint" do
      pdf_content = "fake-pdf-content"

      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, _headers ->
        assert url =~ "/forms/pdfengines/split"

        file_field = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        assert not is_nil(file_field)

        {:ok, %{status: 200, body: "fake-split-pdfs", headers: %{}}}
      end)

      assert {:ok, %{body: "fake-split-pdfs"}} = Pdf.split_pdf([{"document.pdf", pdf_content}])
    end

    test "encodes split options correctly" do
      pdf_content = "fake-pdf"

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

      Pdf.split_pdf(
        [{"document.pdf", pdf_content}],
        split_mode: "page",
        split_span: "1-5",
        split_unify: false
      )
    end
  end

  describe "flatten_pdf/1" do
    test "makes POST request to flatten endpoint" do
      pdf_content = "fake-pdf-content"

      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, _headers ->
        assert url =~ "/forms/pdfengines/flatten"

        file_field = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        assert not is_nil(file_field)
        {_, {content, opts}} = file_field
        assert content == pdf_content
        assert opts[:filename] == "document.pdf"

        {:ok, %{status: 200, body: "fake-flattened-pdf", headers: %{}}}
      end)

      assert {:ok, %{body: "fake-flattened-pdf"}} =
               Pdf.flatten_pdf([{"document.pdf", pdf_content}])
    end

    test "handles multiple PDF files for flattening" do
      pdf1_content = "fake-pdf-1"
      pdf2_content = "fake-pdf-2"

      files = [
        {"doc1.pdf", pdf1_content},
        {"doc2.pdf", pdf2_content}
      ]

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        file_1 = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        file_2 = Enum.find(form_data, fn {key, _} -> key == "file_2" end)

        assert not is_nil(file_1)
        assert not is_nil(file_2)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Pdf.flatten_pdf(files)
    end
  end
end
