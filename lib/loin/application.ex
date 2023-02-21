defmodule Loin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Ensures proper environment validation
    Loin.Config.validate!()

    children = [
      # Start the Telemetry supervisor
      LoinWeb.Telemetry,
      # Start the Ecto repository
      Loin.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Loin.PubSub},
      # Start Finch
      {Finch, name: Loin.Finch},
      # Cache ETF constituents
      Supervisor.child_spec({Cachex, [name: :etf_constituents_cache, stats: true, warmers: []]},
        id: :etf_constituents_cache
      ),
      # Cache ETF sector weights
      Supervisor.child_spec({Cachex, [name: :etf_sector_weight_cache, stats: true, warmers: []]},
        id: :etf_sector_weight_cache
      ),
      # Cache peers data
      Supervisor.child_spec({Cachex, [name: :peers_cache, stats: true, warmers: []]},
        id: :peers_cache
      ),
      # Cache the stock ETF exposure data
      Supervisor.child_spec({Cachex, [name: :stock_etf_exposure_cache, stats: true, warmers: []]},
        id: :stock_etf_exposure_cache
      ),
      # Cache timeseries data
      Supervisor.child_spec({Cachex, [name: :timeseries_cache, stats: true, warmers: []]},
        id: :timeseries_cache
      ),
      # Start the Endpoint (http/https)
      LoinWeb.Endpoint,
      # Realtime Quotes buffer
      {Loin.FMP.RealtimeQuotesBuffer, []},
      # # Realtime Quotes cache
      {Loin.FMP.RealtimeQuotesClient, []},
      # Start the Oban jobs processor
      {Oban, oban_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Loin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LoinWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config() do
    Application.fetch_env!(:loin, Oban)
  end
end
