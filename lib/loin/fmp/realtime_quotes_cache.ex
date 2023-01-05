defmodule Loin.RealtimeQuotesCache do
  @url "wss://streamer.finance.yahoo.com"

  use WebSockex

  def start_link(_opts) do
    WebSockex.start_link(@url, __MODULE__, %{}, name: __MODULE__)
  end

  def handle_cast(message, state) do
    IO.inspect(message, label: "handle_cast")
    {:reply, message, state}
  end

  def handle_connect(connection, state) do
    IO.inspect(connection, label: "handle_connect")
    IO.inspect(state, label: "handle_connect_state")
    {:ok, state}
  end

  def handle_disconnect(status, state) do
    IO.inspect(status, label: "handle_disconnect")
    {:reconnect, state}
  end

  def handle_frame({:text, proto_msg} = frame, state) do
    IO.inspect(frame, label: "handle_frame")
    decoded_msg = proto_msg
      |> Base.decode64!()
      |> IO.iodata_to_binary()
      |> Loin.FMP.PricingData.Ticker.decode()
      |> IO.inspect()

    {:ok, state}
  end

  def handle_info(message, state) do
    IO.inspect(message, label: "handle_info")
    {:ok, state}
  end

  def subscribe_to_sp500() do
    subscribe_message = Loin.FMP.Service.sp500_companies_symbols()
    |> MapSet.to_list()
    |> then(fn symbols -> %{"subscribe" => symbols} end)
    |> Jason.encode!()

    WebSockex.send_frame(__MODULE__, {:text, subscribe_message})
  end

  def terminate(reason, state) do
    IO.inspect(reason, label: "Terminate reason")
    IO.inspect(state, label: "State at termination")
  end
end
