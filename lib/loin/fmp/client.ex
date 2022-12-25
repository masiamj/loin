defmodule Loin.FMP.Client do
  @moduledoc """
  A SPOF that safely throttles requests to FMP.

  THIS IS NOT CURRENTLY USED.
  """
  use ExternalService.Gateway,
    fuse: [
      # Tolerate 5 failures for every 1 second time window.
      strategy: {:standard, 2, 1_000},
      # Reset the fuse 5 seconds after it is blown.
      refresh: 5_000
    ],
    # Limit to 600 calls per minute.
    rate_limit: {600, :timer.seconds(60)},
    retry: [
      backoff: {:linear, 100, 1},
      expiry: 5_000
    ]

  def call(executable_fn) do
    external_call(fn ->
      case executable_fn.() do
        {:ok, result} -> {:ok, result}
        {:error, reason} -> {:retry, reason}
      end
    end)
  end
end
