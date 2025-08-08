defmodule GotenbergElixir.HttpClient.Behaviour do
  @moduledoc """
  Behaviour for HTTP client implementations.
  """

  @type headers :: [{String.t(), String.t()}] | %{String.t() => String.t()}
  @type body :: binary() | {:multipart, list()}

  @type response :: %{
          status: integer(),
          headers: headers(),
          body: binary()
        }

  @type error :: %{
          reason: atom() | String.t(),
          message: String.t()
        }

  @callback get(url :: String.t(), headers :: headers()) ::
              {:ok, response()} | {:error, error()}

  @callback post(url :: String.t(), body :: body(), headers :: headers()) ::
              {:ok, response()} | {:error, error()}
end
