defmodule TodoTxt.MixProject do
  use Mix.Project

  def project do
    [
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_file: {:no_warn, "todotxt_elixir.plt"}
      ],
      app: :todotxt_elixir,
      version: "0.0.1",
      elixir: "~> 1.12.2",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:credo, "~> 1.5.5", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.23.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13.0", only: :test},
      {:file_system, "~> 0.2"},
      {:git_hooks, "~> 0.5.2", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0.2", only: :dev, runtime: false},
      {:nimble_parsec, "~> 1.1.0"},
      {:recon_ex, "~> 0.9.1"}
    ]
  end
end
