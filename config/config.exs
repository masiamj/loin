# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :loin,
  ecto_repos: [Loin.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :loin, LoinWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: LoinWeb.ErrorHTML, json: LoinWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Loin.PubSub,
  live_view: [signing_salt: "AKKNsSBD"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :loin, Loin.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configuration for our feature flags library
config :fun_with_flags, :cache, enabled: false

config :fun_with_flags, :persistence,
  adapter: FunWithFlags.Store.Persistent.Ecto,
  repo: Loin.Repo,
  ecto_table_name: "fun_with_flags_toggles"

config :fun_with_flags, :cache_bust_notifications,
  enabled: true,
  adapter: FunWithFlags.Notifications.PhoenixPubSub,
  client: Loin.PubSub

config :money,
  # this allows you to do Money.new(100)
  default_currency: :USD,
  # change the default thousands separator for Money.to_string
  separator: ",",
  # change the default decimal delimiter for Money.to_string
  delimiter: ".",
  # don’t display the currency symbol in Money.to_string
  symbol: true,
  # position the symbol
  symbol_on_right: false,
  # add a space between symbol and number
  symbol_space: false,
  # display units after the delimiter
  fractional_unit: true,
  # don’t display the insignificant zeros or the delimiter
  strip_insignificant_zeros: false,
  # add the currency code after the number
  code: false,
  # display the minus sign before the currency symbol for Money.to_string
  minus_sign_first: true,
  # don't display the delimiter or fractional units if the fractional units are only insignificant zeros
  strip_insignificant_fractional_unit: false

# Admin tooling configuration
config :kaffy,
  otp_app: :loin,
  ecto_repo: Loin.Repo,
  router: LoinWeb.Router

config :loin, Oban,
  repo: Loin.Repo,
  plugins: [
    # {Oban.Plugins.Pruner, max_age: 300},
    {Oban.Plugins.Cron,
     crontab: [
       # 6:30PM Mon-Fri EST
       {"30 23 * * MON-FRI", Loin.Workers.DailyTrendPrimer},
       # 12:30AM Mon-Fri EST
       {"30 5 * * MON-FRI", Loin.Workers.DailyTrendPruner},
       # Every half hour between 6AM-6:30PM Mon-Fri EST
       {"*/30 11-23 * * MON-FRI", Loin.Workers.QuotesPrimer}
     ]}
  ],
  queues: [default: 10]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
