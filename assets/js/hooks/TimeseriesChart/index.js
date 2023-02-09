import { createChart, CrosshairMode, LineStyle } from 'lightweight-charts';
import get from 'lodash/get'
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
  }
}

const calculateReturnPercentage = (last = {}, current = {}) => {
  if (last && last.close > 0) {
    return Math.round(((current.close - last.close) / last.close) * 100)
  }

  return null
}

const isImportantTrendChange = (item = {}) => {
  switch (get(item, ['trend_change'], null)) {
    case 'down_to_neutral':
    case 'up_to_neutral':
    case 'up_to_down':
    case 'down_to_up':
      return true
    default:
      return false
  }

}

const getMarkers = (completeDataset = []) => {
  const { list } = completeDataset.reduce((acc, current) => {
    const latestItem = get(acc, ['latest'], {})
    const latestTrendChange = get(latestItem, ['trend_change'], null)
    const currentTrendChange = get(current, ['trend_change'], null)
    const isOngoingTrend = isEqual(latestTrendChange, currentTrendChange)

    if (!isOngoingTrend) {
      if (isImportantTrendChange(current)) {
        const returnPercentage = calculateReturnPercentage(latestItem, current)
        acc.list.push({ time: current.date, color: '#64748b', shape: 'circle', text: `${returnPercentage}%`, position: 'aboveBar', size: 0 })
      }
      acc.latest = current
    }

    return acc
  }, { list: [], latest: first(completeDataset) })
  return list
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
      // watermark: {
      //   visible: true,
      //   fontSize: 18,
      //   horzAlign: 'top',
      //   vertAlign: 'left',
      //   color: 'rgba(58,130,246,0.5)',
      //   text: 'TrendFlares',
      // },
    })
  },
  getTimeseriesData() {
    const serializedData = this.el.dataset.timeseries || '[]'
    const deserializedData = JSON.parse(serializedData)
    return deserializedData
  },
  mounted() {
    this.createChart()
    this.renderChart()
  },
  renderChart() {
    const data = this.getTimeseriesData()
    console.log(data)

    /**
     * Data for price line
     */
    const chartData = data.map(({ close, date, trend } = {}) => ({
      color: getColorForItem({ trend }),
      time: date,
      value: close
    }))


    /**
     * Create marker line
     */
    // const markerData = data.map(({ date, trend }) => ({
    //   color: getColorForItem({ trend }),
    //   time: date,
    //   value: 0
    // }))

    // const markers = getMarkers(data)

    /**
     * Handle changing chart data (clear and reset)
     */
    if (this.lineSeries) {
      this.chartInstance.removeSeries(this.lineSeries)
      // this.chartInstance.removeSeries(this.markerSeries)
      this.lineSeries = null
      this.markerSeries = null
    }

    /**
     * Creates series on persistent chart instance
     */
    this.lineSeries = this.chartInstance.addLineSeries();
    this.lineSeries.setData(chartData);

    /**
     * Creates custom marker series
     */
    // this.markerSeries = this.chartInstance.addLineSeries({
    //   baseLineVisible: false,
    //   crosshairMarkerVisible: false,
    //   lastValueVisible: false,
    //   priceLineVisible: false,
    //   lineWidth: 4
    // });
    // this.markerSeries.setData(markerData);
    // this.markerSeries.setMarkers(markers)

    /**
     * Scale to constraints
     */

    this.chartInstance.timeScale().setVisibleRange({
      from: (new Date("2021/09/01")).getTime() / 1000,
      to: (new Date()).getTime() / 1000,
    })
  },
  updated() {
    this.renderChart()
  }
}