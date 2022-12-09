defmodule Scitree.MixProject do
  use Mix.Project

  @version "0.1.0"
  @github_url "https://github.com/jeantux/scitree"

  def project do
    [
      app: :scitree,
      version: @version,
      elixir: "~> 1.13",
      description: "A collection of state-of-the-art algorithms for Decision Forest.",
      start_permanent: Mix.env() == :prod,
      docs: docs(),
      deps: deps(),
      package: package(),
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_precompiler: {:nif, CCPrecompiler},
      make_precompiler_url:
        "https://github.com/jeantux/scitree/releases/download/v#{@version}/@{artefact_filename}",
      make_precompiler_filename: "scitree",
      make_precompiler_priv_paths: ["scitree.*"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      main: "scitree",
      source_ref: "v#{@version}",
      source_url: @github_url
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.6", runtime: false},
      {:cc_precompiler, "~> 0.1.0", runtime: false},
      {:nx, "~> 0.1.0"},

      # docs
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "scitree",
      licenses: ["Apache-2.0"],
      files: ~w(lib c_src mix.exs README* LICENSE* Makefile checksum.exs),
      links: %{"GitHub" => @github_url}
    ]
  end
end
