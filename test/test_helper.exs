Application.put_env(:gotenberg_elixir, :http_client, HttpClientMock)
Application.put_env(:gotenberg_elixir, :base_url, "http://localhost:3000")
ExUnit.start()
