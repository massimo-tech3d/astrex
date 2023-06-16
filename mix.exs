defmodule Astrex.MixProject do
  use Mix.Project

  def project do
    [
      app: :astrex,
      version: "0.3.4",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "My App",
      source_url: "https://github.com/USER/PROJECT",
      homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
      docs: [
        # The main page in the docs
        main: "Astrex",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:math, "~> 0.6.0"},
      {:csv, "~> 3.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
