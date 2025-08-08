defmodule GotenbergElixir do
  @moduledoc """
  Main module for the Gotenberg Elixir client library.
  """

  alias GotenbergElixir.HttpClient

  @doc """
  Checks the health of the Gotenberg service.

  Returns `{:ok, response}` on success or `{:error, error}` on failure.
  """
  @spec health() :: {:ok, HttpClient.response()} | {:error, HttpClient.error()}
  def health do
    url = GotenbergElixir.Config.base_url() <> "/health"
    HttpClient.get(url)
  end

  @doc """
  Gets version information from the Gotenberg service.
  """
  @spec version() :: {:ok, HttpClient.response()} | {:error, HttpClient.error()}
  def version do
    url =
      GotenbergElixir.Config.base_url() <> "/version"

    HttpClient.get(url)
  end
end
