<p align="center">
  <img width="150" alt="gotenberg-elixir" src="https://github.com/user-attachments/assets/aab9459b-c73c-4631-8d04-4c615715eaae"  />
  <h3 align="center">Gotenberg Elixir</h3>
  <p align="center">An elixir client for interacting with Gotenberg</p>
</p>

<p align="center">
  <a href="https://github.com/etiennelacoursiere/gotenberg-elixir/actions">
    <img alt="CI Status" src="https://github.com/etiennelacoursiere/gotenberg-elixir/actions/workflows/ci.yml/badge.svg">
  </a>
</p>

---

> [!WARNING]
> This is a work in progress use at your own risk.

## Implemented
- [x] health check, version
- [x] Chromium routes
- [x] LibreOffice routes
- [X] PDF routes

## TODO
- [ ] Metrics
- [ ] Webhooks
- [ ] Probably more

## Quick examples
Convert a target URL to PDF
```elixir
{:ok, %{body: pdf}} = GotenbergElixir.Chromium.url_into_pdf("https://example.com")
File.write!("my_pdf.pdf", pdf)
```

Convert html into PDF
```elixir
html = "<html><body><h1>Hello World</h1></body></html>"
{:ok, %{body: pdf}} = GotenbergElixir.Chromium.html_file_into_pdf(html)
File.write!("my_pdf.pdf", pdf)

# Add header, footer, images, etc. that you can reference in your index.html
{:ok, %{body: pdf}} =
  GotenbergElixir.Chromium.html_file_into_pdf(
    html_file,
    [
      {"style.css", css_file},
      {"header.html", header_file},
      {"footer.html", footer_file}
    ]
  )

File.write!("my_pdf.pdf", pdf)
```

Convert Office documents to PDF
```elixir
{:ok, %{body: pdf}} = GotenbergElixir.LibreOffice.convert([{"my_file.docx", docx_file}])
File.write!("my_pdf.pdf", pdf)

# You can convert multiple files at once
{:ok, %{body: pdf}} = GotenbergElixir.LibreOffice.convert([
  {"my_file.docx", docx_file},
  {"my_file.xls", xls_file},
  {"my_file.ppt", ppt_file}
])

Enum.each(body, fn {filename, content} ->
  File.write!(filename, content)
end)
```
