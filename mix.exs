defmodule Scitree.MixProject do
  use Mix.Project

  def project do
    [
      app: :scitree,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:elixir_make] ++ Mix.compilers()
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
      {:elixir_make, "~> 0.4", runtime: false},
      {:nx, "~> 0.1.0", override: true},
      {:scholar, "~> 0.1.0", github: "elixir-nx/scholar"}
    ]
  end
end
