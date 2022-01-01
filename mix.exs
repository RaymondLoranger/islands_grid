defmodule Islands.Grid.MixProject do
  use Mix.Project

  def project do
    [
      app: :islands_grid,
      version: "0.1.18",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      name: "Islands Grid",
      source_url: source_url(),
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/islands_grid"
  end

  defp description do
    """
    A grid (map of maps) and functions for the Game of Islands.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
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
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:io_ansi_plus, "~> 0.1"},
      {:islands_board, "~> 0.1"},
      {:islands_coord, "~> 0.1"},
      {:islands_guesses, "~> 0.1"},
      {:islands_island, "~> 0.1"}
    ]
  end
end
