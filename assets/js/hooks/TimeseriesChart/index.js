import { createChart, CrosshairMode, LineStyle } from 'lightweight-charts';
import get from 'lodash/get'
import update from 'lodash/update'

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
  getTimeseriesData() {
    this.hasRealtimeUpdate = false
    const serializedData = this.el.dataset.timeseries || '[]'
    let deserializedData = JSON.parse(serializedData)

    const serializedRealtimeUpdate = this.el.dataset['realtimeUpdate'] || '{}'
    const deserializedRealtimeUpdate = JSON.parse(serializedRealtimeUpdate)

    if (get(deserializedRealtimeUpdate, 'price', false)) {
      this.hasRealtimeUpdate = true
      // const dateString = (new Date()).toISOString().split('T')[0]
      return update(deserializedData, deserializedData.length - 1, (value = {}) => ({ ...value, close: deserializedRealtimeUpdate.price, trend: 'now' }))
    }

    return deserializedData
  },
  mounted() {
    this.createChart()
    this.renderChart()
  },
  renderChart() {
    const data = this.getTimeseriesData()

    /**
     * Data for price line
     */
    const chartData = data.map(({ close, date, trend } = {}) => ({
      color: getColorForItem({ trend }),
      time: date,
      value: close
    }))

    /**
    * Handle changing chart data (clear and reset)
    */
    if (this.lineSeries) {
      this.chartInstance.removeSeries(this.lineSeries)
      this.lineSeries = null
    }

    /**
     * Creates series on persistent chart instance
     */
    this.lineSeries = this.chartInstance.addLineSeries({
      lastPriceAnimation: 2
    });
    this.lineSeries.setData(chartData);

    /**
     * Scale to constraints
     */
    if (!this.hasRealtimeUpdate) {
      this.chartInstance.timeScale().setVisibleRange({
        from: (new Date("2021/09/01")).getTime() / 1000,
        to: (new Date()).getTime() / 1000,
      })
    }
  },
  updated() {
    this.renderChart()
  }
}