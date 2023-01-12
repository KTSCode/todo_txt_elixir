import Config

# somewhere in your config file
if Mix.env() == :dev do
  config :git_hooks,
    auto_install: true,
    verbose: true,
    branches: [
      blacklist: ["main"]
    ],
    hooks: [
      pre_commit: [
        tasks: [
          {:cmd, "mix format --check-formatted"}
        ]
      ],
      pre_push: [
        verbose: false,
        tasks: [
          {:cmd, "mix clean"},
          {:cmd, "mix compile --warnings-as-errors"},
          {:cmd, "mix credo --strict"},
          {:cmd, "mix test --color"},
          {:cmd, "mix dialyzer --format dialyxir"},
          {:cmd, "echo 'success!'"}
        ]
      ]
    ]
end
