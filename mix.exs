defmodule Astrex.MixProject do
  use Mix.Project

  def project do
    [
      app: :astrex,
      version: "0.5.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Astrex",
      source_url: "https://github.com/massimo-tech3d/astrex",
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
      {:math, "~> 0.7.0"},
      {:csv, "~> 3.2.2"},
      {:ex_doc, "~> 0.38.2", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Calculations for astronomy in Elixir: coordinates conversions, planets and DSO positions etc."
  end

  defp package do
    [
      # These are the default files included in the package
      files: ~w(lib priv .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/massimo-tech3d/astrex"}
    ]
  end
end
