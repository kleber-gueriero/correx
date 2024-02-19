defmodule Correx.MixProject do
  use Mix.Project

  @source_url "https://github.com/kleber-gueriero/correx"
  @version "0.1.0"
  def project do
    [
      app: :correx,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Correx",
      source_url: @source_url,
      description: "Correx is a client for Brazilian's shipping carrier \"Correios\"",
      package: package(),
      docs: docs(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: ~w[underspecs overspecs race_conditions error_handling unmatched_returns]a
      ]
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
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:tesla, "~> 1.4"},
      {:finch, "~> 0.8.0"},
      {:sweet_xml, "~> 0.7.1"},
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      description: "Brazilian's Correios (non-official) client for Elixir",
      links: %{
        GitHub: @source_url,
        Changelog: "#{@source_url}/blob/master/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md",
      ],
    ]
  end
end
