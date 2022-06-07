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
      package: package()
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
end
