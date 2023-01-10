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
      # Cache timeseries data
      Supervisor.child_spec({Cachex, [name: :timeseries_data, stats: true, warmers: []]},
        id: :timeseries_data
      ),
      # Start the Endpoint (http/https)
      LoinWeb.Endpoint
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
end
