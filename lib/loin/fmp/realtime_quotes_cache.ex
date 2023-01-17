defmodule Loin.RealtimeQuotesCache do
  @url "wss://websockets.financialmodelingprep.com"

  require Logger
  use WebSockex

  def start_link(_opts) do
    Logger.info("Starting RealtimeQuotesCache...")
    WebSockex.start_link(@url, __MODULE__, %{})
  end

  def handle_cast({:send_message, message}, state) do
    Logger.info("Sending RealtimeQuotesCache message: #{message}")
    {:reply, {:text, message}, state}
  end

  def handle_connect(_connection, state) do
    Logger.info("RealtimeQuotesCache connected to FMP")
    login()
    {:ok, state}
  end

  def handle_disconnect(status, state) do
    Logger.error(
      "RealtimeQuotesCache disconnected from FMP... with status #{status} reconnecting..."
    )

    {:reconnect, state}
  end

  def handle_frame({:text, message}, state) do
    message
    |> Jason.decode!()
    |> handle_frame_content(state)
  end

  def terminate(reason, state) do
    Logger.error("RealtimeQuotesCache terminated because #{reason}, #{state}")
  end

  defp handle_frame_content(%{"event" => "login"}, state) do
    Logger.info("RealtimeQuotesCache authenticated successfully")
    # subscribe_to_all()
    subscribe_to_many([
      "AAPL",
      "MSFT",
      "GOOGL",
      "SPY",
      "SQQQ",
      "SPGP",
      "TSLA",
      "KRUS",
      "UAL",
      "NWN"
    ])

    {:ok, state}
  end

  defp handle_frame_content(%{"s" => symbol, "type" => "T"} = _trade, state) do
    proper_symbol = String.upcase(symbol)
    Logger.info("Processed realtime quote for #{proper_symbol}")
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

  defp subscribe_to_many(symbols) when is_list(symbols) do
    symbols
    |> Enum.map(fn symbol ->
      Jason.encode!(%{"event" => "subscribe", "data" => %{"ticker" => symbol}})
    end)
    |> Enum.each(fn message -> WebSockex.cast(self(), {:send_message, message}) end)
  end
end
