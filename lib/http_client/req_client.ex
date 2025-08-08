defmodule GotenbergElixir.HttpClient.ReqClient do
  @moduledoc """
  HTTP client implementation using the Req library.
  """

  @behaviour GotenbergElixir.HttpClient.Behaviour

  alias GotenbergElixir.HttpClient.Behaviour

  @impl Behaviour
  def get(url, headers \\ []) do
    url
    |> Req.get(headers: headers)
    |> normalize_response()
  end

  @impl Behaviour
  def post(url, {:multipart, form_data}, headers \\ []) do
    [method: :post, url: url, headers: headers, form_multipart: form_data]
    |> Req.new()
    |> Req.post()
    |> normalize_response()
  end

  defp normalize_response({:ok, %Req.Response{status: status, headers: headers, body: body}}) do
    {:ok, %{status: status, headers: Map.new(headers), body: body}}
  end

  defp normalize_response({:error, %Req.TransportError{reason: reason}}) do
    {:error, %{reason: reason, message: "Transport error: #{inspect(reason)}"}}
  end
end
