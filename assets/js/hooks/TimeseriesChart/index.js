import { createChart, CrosshairMode, LineStyle } from 'lightweight-charts';
import get from 'lodash/get'
import update from 'lodash/update'
import first from 'lodash/first'
import isEqual from 'lodash/isEqual'

const getColorForItem = (item) => {
  switch (get(item, ['trend'], null)) {
    case null:
      return '#4b5563'
    case 'up':
      return '#16a34a'
    case 'down':
      return '#dc2626'
    case 'neutral':
      return '#ca8a04'
    case 'now':
      return '#6d28d9'
  }
}

export const TimeseriesChart = {
  createChart() {
    this.chartInstance = createChart(this.el, {
      crosshair: {
        mode: CrosshairMode.Magnet,
        vertLine: { color: '#0f172a', style: LineStyle.SparseDotted, labelBackgroundColor: '#1e40af' },
        horzLine: { color: '#0f172a', style: LineStyle.SparseDotted, labelBackgroundColor: '#1e40af' },
      },
      layout: {
        background: { color: '#f8fafc' },
        textColor: '#475569'
      },
      grid: {
        vertLines: { color: '#e2e8f0' },
        horzLines: { color: '#e2e8f0' },
      },
      rightPriceScale: {
        borderVisible: false
      },
      timeScale: {
        borderVisible: false
      },
    })
  },
  mounted() {
    this.chartSourceData = []
    this.isValidRealtimeUpdate = false

    this.createChart()
    this.setTimeseriesData()
    this.renderChart()
  },
  renderChart() {
    /**
     * Data for price line
     */
    const { chartData, day200SMAs, day50SMAs } = this.chartSourceData.reduce((acc, { close, date, day_200_sma, day_50_sma, trend }) => {
      acc.chartData.push({
        color: getColorForItem({ trend }),
        time: date,
        value: close
      })

      acc.day200SMAs.push({
        color: '#10b981',
        time: date,
        value: day_200_sma
      })

      acc.day50SMAs.push({
        color: '#0ea5e9',
        time: date,
        value: day_50_sma
      })

      return acc
    }, { chartData: [], day200SMAs: [], day50SMAs: [] })

    /**
    * Handle changing chart data (clear and reset)
    */
    if (this.lineSeries) {
      this.chartInstance.removeSeries(this.lineSeries)
      this.chartInstance.removeSeries(this.day200SMAsSeries)
      this.chartInstance.removeSeries(this.day50SMAsSeries)
      this.lineSeries = null
      this.day200SMAsSeries = null
      this.day50SMAsSeries = null
    }

    /**
     * Creates series on persistent chart instance
     */
    this.lineSeries = this.chartInstance.addLineSeries({
      lastPriceAnimation: 2
    });

    this.lineSeries.setData(chartData);

    /**
     * Creates SMA series
     */
    this.day200SMAsSeries = this.chartInstance.addLineSeries({
      crosshairMarkerVisible: false,
      lastValueVisible: false,
      lineWidth: 0.5,
      priceLineVisible: false,
    })
    this.day200SMAsSeries.setData(day200SMAs)

    this.day50SMAsSeries = this.chartInstance.addLineSeries({
      crosshairMarkerVisible: false,
      lastValueVisible: false,
      lineWidth: 0.5,
      priceLineVisible: false,
    })
    this.day50SMAsSeries.setData(day50SMAs)

    /**
     * Manages legend
     */
    if (!this.el.dataset.hideLegend) {
      this.renderLegend()
    }

    /**
     * Scale to constraints
     */
    if (!this.isValidRealtimeUpdate) {
      this.chartInstance.timeScale().setVisibleRange({
        from: (new Date("2021/09/01")).getTime() / 1000,
        to: (new Date()).getTime() / 1000,
      })
    }
  },
  renderLegend() {
    document.body.style.position = 'relative';
    const legendContainer = document.createElement('div')
    legendContainer.classList.add('chart-legend');
    this.el.appendChild(legendContainer);

    const dateRow = document.createElement('div')
    const priceRow = document.createElement('div')
    const day50SMARow = document.createElement('div')
    day50SMARow.style.color = '#0ea5e9'
    const day200SMARow = document.createElement('div')
    day200SMARow.style.color = '#10b981'

    legendContainer.appendChild(dateRow)
    legendContainer.appendChild(priceRow)
    legendContainer.appendChild(day50SMARow)
    legendContainer.appendChild(day200SMARow)

    this.chartInstance.subscribeCrosshairMove((param) => {
      if (param.time && this.lineSeries && this.day50SMAsSeries && this.day200SMAsSeries) {
        dateRow.innerText = `${param.time.month}/${param.time.day}/${param.time.year}`
        priceRow.innerText = `Close ${param.seriesPrices.get(this.lineSeries)?.toFixed(2)}`
        day50SMARow.innerText = `50D SMA ${param.seriesPrices.get(this.day50SMAsSeries)?.toFixed(2)}`
        day200SMARow.innerText = `200D SMA ${param.seriesPrices.get(this.day200SMAsSeries)?.toFixed(2)}`
      }
    });
  },
  setRealtimeDataPoint() {
    const incomingRealtimeUpdate = JSON.parse(this.el.dataset.realtimeUpdate || '{}')
    this.isValidRealtimeUpdate = get(incomingRealtimeUpdate, 'price', false)

    if (this.isValidRealtimeUpdate) {
      this.chartSourceData = update(this.chartSourceData, this.chartSourceData.length - 1, (value = {}) => ({ ...value, close: incomingRealtimeUpdate.price, trend: 'now' }))
    }
  },
  setTimeseriesData() {
    const incomingData = JSON.parse(this.el.dataset.timeseries || '[]')
    if (!isEqual(first(incomingData), first(this.chartSourceData))) {
      this.isValidRealtimeUpdate = false
      this.chartSourceData = incomingData
    }
  },
  updated() {
    this.setTimeseriesData()
    this.setRealtimeDataPoint()
    this.renderChart()
  }
}