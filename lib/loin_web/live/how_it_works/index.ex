defmodule LoinWeb.HowItWorksLive do
  use LoinWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8 lg:py-16 bg-white min-h-screen">
      <article class="prose max-w-2xl mx-auto">
        <h1>How TrendFlares works</h1>
        <h3>TrendFlares is a system to identify and surface stock trends.</h3>
        <p>
          Most professional investors typically <strong>underperform</strong>
          the market.  The percentage changes depending on the study and time period, but generally most actively managed funds do not regularly outperform their benchmark.
        </p>
        <p>
          A study by Morningstar found that, on average <strong>only about 24% of actively managed US equity funds outperformed their benchmark index over the 10-year period ending in December 2019</strong>. Another S&P Dow Jones Indices study found that, <strong>over the 15 years ending in December 2019, only about 18% of actively managed US equity funds outperformed their benchmark index</strong>.
        </p>
        <p>We created TrendFlares as a tool to help ourselves outperform the market.</p>
        <p>
          TrendFlares helps us take advantage of <em>momentum</em>
          by making it trivial to identify and track stock trends.
        </p>
        <p class="p-2 rounded-md bg-blue-50 text-blue-500 border border-blue-500">
          Momentum investors identify and take long positions in stocks with strong recent performance with the assumption that they will continue to perform well in the near future.
        </p>
        <p>
          Studies have shown that <em>momentum strategies</em>
          tend to outperform the overall stock market. This is driven by the idea that stocks currently performing well are likely to continue doing so because of <strong>positive investor sentiment, positive earnings reports, and strong fundamentals</strong>.
        </p>
        <p>
          One of the reasons momentum tends to outperform is that it takes advantage of investors' <em>behavioral biases</em>. For example, investors often tend to overreact to news and events, buying stocks that have recently risen in price and selling stocks that have recently fallen in price. By investing in stocks that have recently increased in price, momentum investors can capture gains from this overreaction.
        </p>
        <p>
          Another reason momentum tends to outperform is that it takes advantage of investors' under-reaction to <em>information</em>. For example, investors often take time to process new information and may not fully incorporate further information into valuations.
        </p>
        <p>
          TrendFlares uses a relatively simple algorithm to identify trends based on the 50-day moving average (SMA) and the 200-day moving average (SMA) of a stock's price. The algorithm relies on three <em>tests</em>:
        </p>
        <ol>
          <li>Does the current stock price exceeds the 50-day DMA?</li>
          <li>Does the current stock price exceed the 200-day DMA.?</li>
          <li>
            Does the 50-day DMA exceed the 200-day DMA?
          </li>
        </ol>
        <p>
          If all three tests pass, the stock is in an uptrend. If more than one of these tests fail, the stock is in a downtrend. The stock is in a neutral trend if two tests pass as we do not classify this as a strong signal.
        </p>
        <p>
          One of the key benefits of using TrendFlares is that it can help identify trend changes before they become widely recognized by other investors, helping maximize returns. Using the application's trend identification algorithm, investors can avoid buying stocks in a downtrend or realize their gains before a stock enters a prolonged downtrend.
        </p>
        <p>
          Using a tool like TrendFlares, investors can systematically identify trends and make data-driven decisions instead of relying on emotions.
        </p>
      </article>
    </div>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "How TrendFlares identifies stock trends")
  end
end
