defmodule Loin.FMP.RealtimeQuotesClient do
  @moduledoc """
  Client for real-time websocket connections for FMP trades.
  """

  @url "wss://websockets.financialmodelingprep.com"

  require Logger
  use WebSockex

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(_opts) do
    Logger.info("Starting RealtimeQuotesClient...")

    WebSockex.start_link(@url, __MODULE__, %{}, [
      {:async, true},
      # {:debug, [:trace]},
      {:name, {:global, :realtime_quotes_client}},
      {:handle_initial_conn_failure, true}
    ])
  end

  def handle_cast({:send_message, message}, state) do
    {:reply, {:text, message}, state}
  end

  def handle_connect(_connection, state) do
    Logger.info("RealtimeQuotesClient connected...")
    login()
    {:ok, state}
  end

  def handle_disconnect(status, state) do
    Logger.error(
      "RealtimeQuotesClient disconnected from FMP... with status #{status} reconnecting..."
    )

    case Loin.Features.is_realtime_quotes_enabled() do
      true ->
        {:reconnect, state}

      false ->
        {:ok, state}
    end
  end

  def handle_frame({:text, message}, state) do
    message
    |> Jason.decode!()
    |> handle_frame_content(state)

    {:ok, state}
  end

  def terminate(reason, state) do
    Logger.error("RealtimeQuotesClient terminated because #{reason}, #{state}")
    :ok
  end

  defp handle_frame_content(%{"event" => "login"}, state) do
    Logger.info("RealtimeQuotesClient authenticated...")
    subscribe_to_all()
    {:ok, state}
  end

  defp handle_frame_content(%{"lp" => latest_price, "s" => symbol, "type" => "T"} = _trade, state) do
    proper_symbol = String.upcase(symbol)
    Loin.FMP.RealtimeQuotesBuffer.put({proper_symbol, latest_price})
    {:ok, state}
  end

  defp handle_frame_content(_frame, state) do
    {:ok, state}
  end

  defp login() do
    message =
      Jason.encode!(%{"event" => "login", "data" => %{"apiKey" => Loin.Config.fmp_api_key()}})

    WebSockex.cast(self(), {:send_message, message})
  end

  defp subscribe_to_all() do
    message = Jason.encode!(%{"event" => "subscribe", "data" => %{"ticker" => "*"}})
    WebSockex.cast(self(), {:send_message, message})
  end
end
