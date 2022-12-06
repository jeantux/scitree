defmodule Scitree.MixProject do
  use Mix.Project

  @version "0.1.0"
  @github_url "https://github.com/jeantux/scitree"

  def project do
    [
      app: :scitree,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.6", runtime: false, github: "elixir-lang/elixir_make", override: true},
      {:cc_precompiler, "~> 0.1.0", runtime: false, github: "cocoa-xu/cc_precompiler"},
      {:nx, "~> 0.1.0", override: true}
    ]
  end

  defp package do
    [
      name: "scitree",
      licenses: ["Apache-2.0"],
      files: ~w(lib c_src mix.exs README* LICENSE* Makefile checksum.exs),
      links: %{"GitHub" => @github_url},
    ]
  end
end
