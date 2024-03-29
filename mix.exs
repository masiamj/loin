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
      ],
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Loin.Application, []},
      extra_applications: [:ex_unit, :logger, :runtime_tools]
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
      {:appsignal, "~> 2.5"},
      {:appsignal_phoenix, "~> 2.3.1"},
      {:bcrypt_elixir, "~> 3.0"},
      {:cachex, "~> 3.4"},
      {:conditional_child, "~> 0.1.1"},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:csv, "~> 3.0"},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:doctor, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.6"},
      {:elixir_auth_google, "~> 1.6.3"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:ex_check, "~> 0.14.0", only: [:dev, :test], runtime: false},
      {:ex_cldr, "~> 2.33"},
      {:ex_cldr_numbers, "~> 2.29"},
      {:ex_cldr_plugs, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:external_service, "~> 1.1"},
      {:familiar, "~> 0.1.1"},
      {:finch, "~> 0.13"},
      {:floki, ">= 0.30.0", only: :test},
      {:flop_phoenix, "~> 0.17.2"},
      {:flow, "~> 1.2"},
      {:fun_with_flags, "~> 1.10"},
      {:fun_with_flags_ui, "~> 0.8.1"},
      {:gettext, "~> 0.20"},
      {:heroicons, "~> 0.5"},
      {:indicado, "~> 0.0.4"},
      {:jason, "~> 1.2"},
      {:kaffy, "~> 0.9.2"},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:oban, "~> 2.13"},
      {:oban_web, "~> 2.9", repo: "oban"},
      {:open_hours, "~> 0.1.0", override: true},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.3"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_view, "~> 2.0"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:remote_file_streamer, "~> 1.0"},
      {:req, "~> 0.3.3"},
      {:singleton, "~> 1.3"},
      {:sobelow, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:swoosh, "~> 1.3"},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:timex, "~> 3.0"},
      {:uuid, "~> 1.1"},
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
