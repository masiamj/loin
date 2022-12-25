defmodule Loin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Ensures proper validation
    ensure_valid_environment!()

    children = [
      # Start the Telemetry supervisor
      LoinWeb.Telemetry,
      # Start the Ecto repository
      Loin.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Loin.PubSub},
      # Start Finch
      {Finch, name: Loin.Finch},
      # Start the Endpoint (http/https)
      LoinWeb.Endpoint
      # Start a worker by calling: Loin.Worker.start_link(arg)
      # {Loin.Worker, arg}
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

  defp ensure_valid_environment!() do
  end
end
