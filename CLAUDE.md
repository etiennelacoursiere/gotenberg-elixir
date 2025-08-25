# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
- `make boot-gotenberg` - Start Gotenberg Docker container on port 3092
- `make start` - Start interactive Elixir shell with mix
- `iex -S mix` - Start interactive Elixir shell

### Testing
- `MIX_ENV=test mix test` - Run all tests
- `MIX_ENV=test mix test test/specific_test.exs` - Run specific test file
- `MIX_ENV=test mix test test/specific_test.exs:line_number` - Run specific test
- `MIX_ENV=test mix test --cover` - Run tests with coverage

### Code Quality
- `mix format` - Format code
- `mix format --check-formatted` - Check if code is formatted
- `mix credo --strict` - Run static code analysis
- `mix compile --warnings-as-errors` - Compile with strict warnings
- `mix deps.unlock --check-unused` - Check for unused dependencies

### Dependencies
- `mix deps.get` - Install dependencies
- `mix deps.compile` - Compile dependencies

## Architecture

This is an Elixir client library for interacting with Gotenberg, a Docker-powered stateless API for converting HTML, Markdown, and Office documents to PDF.

### Key Modules
- `GotenbergElixir` - Main module with health check and version endpoints
- `GotenbergElixir.Chromium` - HTML/URL to PDF conversion using Chromium
- `GotenbergElixir.LibreOffice` - Office document to PDF conversion
- `GotenbergElixir.PDF` - PDF manipulation operations
- `GotenbergElixir.HttpClient` - HTTP client abstraction with behavior pattern
- `GotenbergElixir.Options` - Encodes options and files for multipart form data
- `GotenbergElixir.Config` - Configuration management

### HTTP Client Pattern
Uses a behavior pattern for HTTP clients:
- `HttpClient.Behaviour` defines the interface
- `HttpClient.ReqClient` is the default implementation using Req library
- `HttpClientMock` for testing (configured in test_helper.exs)

### Configuration
Configuration is environment-based:
- Test environment uses mocked HTTP client and localhost:3000
- Production uses actual Gotenberg service URL and Req HTTP client

### Testing Strategy
- Uses Mox for mocking HTTP client behavior
- Tests are organized by module (chromium_test.exs, libre_office_test.exs, etc.)
- Integration tests require running Gotenberg container via Docker
- Environment variable MIX_ENV=test enables test configuration

### Form Data Encoding
All requests to Gotenberg use multipart form data:
- Files are encoded as file uploads
- Options are converted from Elixir keyword lists to form fields
- The `Options` module handles snake_case to kebab-case conversion for Gotenberg compatibility