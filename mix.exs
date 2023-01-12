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
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      app: :todo_txt,
      version: "0.2.0-dev",
      elixir: "~> 1.14.2",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      # Docs
      name: "TodoTxt",
      source_url: "https://github.com/KTSCode/todo_txt",
      docs: [
        # The main page in the docs
        main: "Todo",
        logo: "todotxt_logo_2012.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "A library for reading/parseing/writing todo.txt files"
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/KTSCode/todo_txt"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.29.1", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13.0", only: :test},
      {:git_hooks, "~> 0.7.3", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 1.0.2", only: :dev, runtime: false},
      {:nimble_parsec, "~> 1.1.0"},
      {:recon, "~> 2.5.2", only: :dev, runtime: false}
    ]
  end
end
