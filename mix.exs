defmodule GotenbergElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :gotenberg_elixir,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Gotenberg Elixir",
      source_url: "https://github.com/etiennelacoursiere/gotenberg-elixir",
      docs: &docs/0
    ]
  end

  defp docs do
    [
      main: "GotenbergElixir",
      extras: ["README.md"],
      logo: "assets/gotenberg-elixir.png"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end
end
