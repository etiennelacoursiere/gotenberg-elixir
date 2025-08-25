defmodule GotenbergElixir.ChromiumTest do
  use ExUnit.Case
  import Mox

  alias GotenbergElixir.Chromium

  setup :verify_on_exit!

  describe "url_into_pdf/2" do
    test "makes POST request to correct endpoint with URL" do
      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, headers ->
        assert url =~ "/forms/chromium/convert/url"
        assert headers == []

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "url" and value == "https://example.com"
               end)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      assert {:ok, %{body: "fake-pdf"}} = Chromium.url_into_pdf("https://example.com")
    end

    test "encodes options correctly with camelCase conversion" do
      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, value} ->
                 key == "paperWidth" and value == "8.5"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "paperHeight" and value == "11"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "printBackground" and value == "true"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "marginTop" and value == "0.5"
               end)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Chromium.url_into_pdf("https://example.com",
        paper_width: 8.5,
        paper_height: 11,
        print_background: true,
        margin_top: 0.5
      )
    end

    test "encodes cookies as JSON" do
      cookies = [
        %{name: "test_cookie", value: "test_value", domain: "example.com"},
        %{name: "session", value: "abc123", domain: "example.com", http_only: true}
      ]

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        cookies_field = Enum.find(form_data, fn {key, _} -> key == "cookies" end)
        assert not is_nil(cookies_field)
        {_, cookies_json} = cookies_field

        assert {:ok, decoded_cookies} = JSON.decode(cookies_json)
        assert is_list(decoded_cookies)
        assert length(decoded_cookies) == 2

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Chromium.url_into_pdf("https://example.com", cookies: cookies)
    end

    test "encodes extra_http_headers as JSON" do
      headers = %{"X-Custom-Header" => "custom-value", "Authorization" => "Bearer token"}

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        headers_field = Enum.find(form_data, fn {key, _} -> key == "extraHttpHeaders" end)
        assert not is_nil(headers_field)
        {_, headers_json} = headers_field

        assert {:ok, decoded_headers} = JSON.decode(headers_json)
        assert decoded_headers["X-Custom-Header"] == "custom-value"
        assert decoded_headers["Authorization"] == "Bearer token"

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Chromium.url_into_pdf("https://example.com", extra_http_headers: headers)
    end

    test "encodes array options correctly" do
      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        fail_codes_field = Enum.find(form_data, fn {key, _} -> key == "failOnHttpStatusCodes" end)
        assert not is_nil(fail_codes_field)
        {_, codes_json} = fail_codes_field

        assert {:ok, decoded_codes} = JSON.decode(codes_json)
        assert decoded_codes == [404, 500, 502]

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Chromium.url_into_pdf("https://example.com", fail_on_http_status_codes: [404, 500, 502])
    end
  end

  describe "url_into_screenshot/2" do
    test "makes POST request to screenshot endpoint" do
      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, _headers ->
        assert url =~ "/forms/chromium/screenshot/url"

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "url" and value == "https://example.com"
               end)

        {:ok, %{status: 200, body: "fake-image", headers: %{}}}
      end)

      assert {:ok, %{body: "fake-image"}} = Chromium.url_into_screenshot("https://example.com")
    end

    test "encodes screenshot-specific options" do
      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, value} ->
                 key == "width" and value == "1200"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "height" and value == "800"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "format" and value == "jpeg"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "clip" and value == "true"
               end)

        {:ok, %{status: 200, body: "fake-image", headers: %{}}}
      end)

      Chromium.url_into_screenshot("https://example.com",
        width: 1200,
        height: 800,
        format: "jpeg",
        clip: true
      )
    end
  end

  describe "html_file_into_pdf/3" do
    test "makes POST request to HTML endpoint with files" do
      html = "<html><body>Test</body></html>"
      css = "body { color: red; }"

      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, _headers ->
        assert url =~ "/forms/chromium/convert/html"

        index_file = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        assert not is_nil(index_file)
        {_, {file_content, opts}} = index_file
        assert file_content == html
        assert opts[:filename] == "index.html"

        css_file = Enum.find(form_data, fn {key, _} -> key == "file_2" end)
        assert not is_nil(css_file)
        {_, {css_content, css_opts}} = css_file
        assert css_content == css
        assert css_opts[:filename] == "style.css"

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Chromium.html_file_into_pdf(html, [{"style.css", css}])
    end

    test "encodes options along with files" do
      html = "<html><body>Test</body></html>"

      expect(HttpClientMock, :post, fn _url, {:multipart, form_data}, _headers ->
        assert Enum.any?(form_data, fn {key, _} -> key == "file_1" end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "waitForExpression" and value == "window.ready === true"
               end)

        assert Enum.any?(form_data, fn {key, value} ->
                 key == "landscape" and value == "true"
               end)

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Chromium.html_file_into_pdf(html, [],
        wait_for_expression: "window.ready === true",
        landscape: true
      )
    end
  end

  describe "html_file_into_screenshot/3" do
    test "makes POST request to screenshot HTML endpoint" do
      html = "<html><body>Test</body></html>"

      expect(HttpClientMock, :post, fn url, {:multipart, _form_data}, _headers ->
        assert url =~ "/forms/chromium/screenshot/html"
        {:ok, %{status: 200, body: "fake-image", headers: %{}}}
      end)

      Chromium.html_file_into_screenshot(html)
    end
  end

  describe "markdown_files_into_pdf/3" do
    test "makes POST request to markdown endpoint with files" do
      index_html = "<html><body>{{ toHTML \"file.md\" }}</body></html>"
      markdown = "# Hello World"

      expect(HttpClientMock, :post, fn url, {:multipart, form_data}, _headers ->
        assert url =~ "/forms/chromium/convert/markdown"

        index_file = Enum.find(form_data, fn {key, _} -> key == "file_1" end)
        assert not is_nil(index_file)
        {_, {content, opts}} = index_file
        assert content == index_html
        assert opts[:filename] == "index.html"

        md_file = Enum.find(form_data, fn {key, _} -> key == "file_2" end)
        assert not is_nil(md_file)
        {_, {md_content, md_opts}} = md_file
        assert md_content == markdown
        assert md_opts[:filename] == "file.md"

        {:ok, %{status: 200, body: "fake-pdf", headers: %{}}}
      end)

      Chromium.markdown_files_into_pdf(index_html, [{"file.md", markdown}])
    end
  end

  describe "markdown_files_into_screenshot/3" do
    test "makes POST request to screenshot markdown endpoint" do
      index_html = "<html><body>{{ toHTML \"file.md\" }}</body></html>"
      markdown = "# Hello World"

      expect(HttpClientMock, :post, fn url, {:multipart, _form_data}, _headers ->
        assert url =~ "/forms/chromium/screenshot/markdown"
        {:ok, %{status: 200, body: "fake-image", headers: %{}}}
      end)

      Chromium.markdown_files_into_screenshot(index_html, [{"file.md", markdown}])
    end
  end
end
