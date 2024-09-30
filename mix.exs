defmodule ExSTARS.MixProject do
  use Mix.Project

  @source_url "https://github.com/tombo-works/ex_stars"

  def project do
    [
      app: :ex_stars,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ] ++ hex() ++ docs()
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExSTARS.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp hex() do
    [
      description: "Elixir STARS library.",
      package: [
        files: ~w"LICENSES lib README.md REUSE.toml mix.exs",
        licenses: ["Apache-2.0"],
        links: %{"GitHub" => @source_url}
      ]
    ]
  end

  defp docs() do
    [
      name: "ExSTARS",
      source_url: @source_url,
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end
end