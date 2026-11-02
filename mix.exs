defmodule GotenbergElixir.MixProject do
  use Mix.Project

  @github "https://github.com/etiennelacoursiere/gotenberg-elixir"
  @version "0.1.0"

  def project do
    [
      app: :gotenberg_elixir,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Gotenberg Elixir",
      source_url: @github,
      docs: &docs/0,
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @github
      },
      description: "An elixir client for interacting with Gotenberg"
    ]
  end

  defp docs do
    [
      main: "GotenbergElixir",
      extras: ["README.md"],
      logo: "assets/gotenberg-elixir.png"
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0 or ~> 0.6.0 or ~> 0.7.2"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.38.3", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end
end
