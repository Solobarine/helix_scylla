defmodule HelixScylla.MixProject do
  use Mix.Project

  def project do
    [
      app: :helix_scylla,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      description: "ScyllaDB migrations for Elixir applications using Exandra",
      package: package(),
      deps: deps(),
      docs: docs()
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
      {:xandra, "~> 0.20.0"},
      {:decimal, "~> 3.1"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      name: "helix_scylla",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Solobarine/helix_scylla"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/Solobarine/helix_scylla",
      extras: ["README.md"]
    ]
  end
end
