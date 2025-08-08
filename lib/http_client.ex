defmodule GotenbergElixir.HttpClient do
  @moduledoc """
  HTTP client facade that delegates to the configured implementation.

  ## Configuration

      config :gotenberg_elixir,
        http_client: GotenbergElixir.HttpClient.ReqClient

  """

  alias GotenbergElixir.HttpClient.Behaviour

  @type headers :: Behaviour.headers()
  @type body :: Behaviour.body()
  @type response :: Behaviour.response()
  @type error :: Behaviour.error()

  @doc """
  Performs a GET request using the configured HTTP client.
  """
  @spec get(String.t(), headers()) :: {:ok, response()} | {:error, error()}
  def get(url, headers \\ []) do
    http_client().get(url, headers)
  end

  @doc """
  Performs a POST request using the configured HTTP client.
  """
  @spec post(String.t(), body(), headers()) :: {:ok, response()} | {:error, error()}
  def post(url, body, headers \\ []) do
    http_client().post(url, body, headers)
  end

  defp http_client, do: GotenbergElixir.Config.http_client()
end
