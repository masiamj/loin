defmodule Loin.MixProject do
  use Mix.Project

  def project do
    [
      app: :loin,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [
        check: :test,
        credo: :test,
        dialyzer: :test,
        doctor: :test,
        sobelow: :test,
        "deps.audit": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Loin.Application, []},
      extra_applications: [:ex_unit, :logger, :runtime_tools, :exprotobuf]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:cachex, "~> 3.4"},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:csv, "~> 3.0"},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:doctor, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.6"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:ex_check, "~> 0.14.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:exprotobuf, "~> 1.2"},
      {:external_service, "~> 1.1"},
      {:finch, "~> 0.13"},
      {:floki, ">= 0.30.0", only: :test},
      {:flow, "~> 1.2"},
      {:fun_with_flags, "~> 1.10"},
      {:fun_with_flags_ui, "~> 0.8.1"},
      {:gettext, "~> 0.20"},
      {:heroicons, "~> 0.5"},
      {:indicado, "~> 0.0.4"},
      {:jason, "~> 1.2"},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:oban, "~> 2.13"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.3"},
      {:phoenix, "~> 1.7.0-rc.0", override: true},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:remote_file_streamer, "~> 1.0"},
      {:req, "~> 0.3.3"},
      {:sobelow, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:swoosh, "~> 1.3"},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:websockex, "~> 0.4.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
