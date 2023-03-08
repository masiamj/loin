defmodule LoinWeb.HowItWorksLive do
  use LoinWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        :page_title,
        "How TrendFlares works: revolutionize your investment strategy with real-time trends and analysis"
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8 lg:py-16 bg-white min-h-screen">
      <article class="prose max-w-2xl mx-auto">
        <h1>How TrendFlares works</h1>
        <h3>TrendFlares is a system to identify and surface stock trends.</h3>
        <h4 class="text-red-500">
          TrendFlares is an algorithm-based, historical stock price analysis system and trends identified do not guarantee future performance. TrendFlares must not be construed as financial advice or investing advice.
        </h4>
        <p>
          Most professional investors typically <strong>underperform</strong>
          in the market.  The percentage of actively managed funds that outperform their benchmark index each year varies depending on the study and the time period being considered. However, in general, most actively managed funds do not outperform their benchmark index each year.
        </p>
        <p>
          One study by Morningstar found that, on average, only about 24% of actively managed US equity funds outperformed their benchmark index over the 10-year period ending in December 2019. Another S&P Dow Jones Indices study found that, over the 15 years ending in December 2019, only about 18% of actively managed US equity funds outperformed their benchmark index.  Given this underperformance, many investors are looking for better solution and hence the reason for creating TrendFlares.
        </p>
        <p>
          TrendFlares is a trend-following application that helps investors stay on the right side of stock price trends and take advantage of the momentum.  In momentum investing, stocks that have performed well in the recent past are identified and invested in with the assumption that they will continue to do well in the future. This strategy is based on the idea that momentum, or the tendency of stocks to continue moving in their current direction, is a powerful force in the stock market.
        </p>
        <p>
          Studies have shown that momentum tends to outperform the stock market. This is because stocks currently performing well are likely to continue performing well due to various factors, such as positive investor sentiment, positive earnings reports, and strong fundamentals.
        </p>
        <p>
          One of the reasons momentum tends to outperform is that it takes advantage of investors' behavioral biases. For example, investors often tend to overreact to news and events, buying stocks that have recently risen in price and selling stocks that have recently fallen in price. By investing in stocks that have recently increased in price, momentum investors can capture gains from this overreaction.
        </p>
        <p>
          Another reason momentum tends to outperform is that it takes advantage of investors' under-reaction to information. For example, investors often take time to process new information and may not fully incorporate further information into stock prices. By investing in stocks that have recently risen in price, momentum investors can capture some of the gains from this under-reaction.
        </p>
        <p>
          TrendFlares uses an algorithm to identify trends based on the 50-day moving average (DMA) and the 200-day moving average (DMA) of a stock's price. The algorithm utilizes three tests:
        </p>
        <ol>
          <li>The first test checks whether the current stock price exceeds the 50-day DMA.</li>
          <li>The second test checks whether the current stock price exceeds the 200-day DMA.</li>
          <li>
            The third test checks if the 50-day DMA is greater than the 200-day DMA.
            If all three tests pass, the stock is in an uptrend. If more than one of these tests fail, the stock is in a downtrend. The stock is in a neutral trend if two tests pass as we do not classify this as a strong signal.
          </li>
        </ol>
        <p>
          In addition to identifying trends, TrendFlares also provides a wealth of other information to investors, including historical stock prices, key stats, and other technical indicators, which can help investors to make more informed decisions about which stocks to buy and sell. In the future, the application will allow users to set their parameters for the 50-day SMA and 200-day SMA to adjust the algorithm to their preferences.
        </p>
        <p>
          One of the key benefits of using TrendFlares is that it can help investors to identify trends early on before they become widely recognized by other investors. By identifying trends early, investors can take advantage of price movements before they become widely known, which can help to maximize their returns. Another benefit of using TrendFlares is that it can help investors to avoid making mistakes that can be costly. Using the application's trend identification algorithm, investors can avoid buying stocks in a downtrend or realize their gains before a stock enters a prolonged downtrend.
        </p>
        <p>
          Using a tool like TrendFlares, investors can have a system in place to identify trends and make data-driven decisions instead of relying on emotions or market rumors, which can help them outperform the market.
        </p>
      </article>
    </div>
    <LoinWeb.FooterComponents.footer />
    """
  end
end
