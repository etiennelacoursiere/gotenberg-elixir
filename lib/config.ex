defmodule GotenbergElixir.Config do
  @moduledoc """
  Configuration module for GotenbergElixir.

  ## Configuration Options

      config :gotenberg_elixir,
        base_url: "http://localhost:3000",
        http_client: GotenbergElixir.HttpClient.ReqClient

  """

  @doc """
  Gets the base URL for the Gotenberg service.
  """
  @spec base_url() :: String.t()
  def base_url do
    Application.fetch_env!(:gotenberg_elixir, :base_url)
  end

  @doc """
  Gets the configured HTTP client module.

  Defaults to GotenbergElixir.HttpClient.ReqClient if not configured.
  """
  @spec http_client() :: module()
  def http_client do
    Application.get_env(:gotenberg_elixir, :http_client, GotenbergElixir.HttpClient.ReqClient)
  end
end
