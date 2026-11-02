defmodule GotenbergElixir do
  @moduledoc """
  Main module for the Gotenberg Elixir client library.
  """

  alias GotenbergElixir.HttpClient

  @doc """
  Checks the health of the Gotenberg service.
  """
  @spec health() ::
          {:ok, HttpClient.Behaviour.response()} | {:error, HttpClient.Behaviour.error()}
  def health do
    url = GotenbergElixir.Config.base_url() <> "/health"
    HttpClient.get(url)
  end

  @doc """
  Gets version information from the Gotenberg service.
  """
  @spec version() ::
          {:ok, HttpClient.Behaviour.response()} | {:error, HttpClient.Behaviour.error()}
  def version do
    url =
      GotenbergElixir.Config.base_url() <> "/version"

    HttpClient.get(url)
  end
end
