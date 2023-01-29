import { createChart, CrosshairMode, LineStyle } from 'lightweight-charts';

const getColorForItem = ({ trend } = {}) => {
  switch (trend) {
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
  console.log({ last, current })
  if (last && last.close > 0) {
    return Math.round(((current.close - last.close) / last.close) * 100)
  }

  return null
}

const getMarkers = (completeDataset = []) => {
  const { list } = completeDataset.reduce((acc, item) => {
    switch (item.trend_change) {
      case 'down_to_up':
      case 'neutral_to_up':
        if (!acc.lastEntry) {
          acc.list.push({ time: item.date, color: 'green', shape: 'arrowUp', text: `Enter`, position: 'belowBar' })
          acc.lastEntry = item
        }
        return acc
      case 'up_to_down':
      case 'neutral_to_down':
        if (acc.lastEntry) {
          acc.list.push({ time: item.date, color: 'red', shape: 'arrowDown', text: `Exit ${calculateReturnPercentage(acc.lastEntry, item)}%`, position: 'aboveBar' })
          acc.lastEntry = null
          acc.lastExit = item
        }
        return acc
      default:
        return acc
    }
  }, { list: [], lastEntry: null, lastExit: null })
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
    console.log(deserializedData)
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
     * Data for volume histogram
     */
    const volumeData = data.map(({ volume, date }) => ({
      color: 'rgba(37,99,235, 0.4)',
      time: date,
      value: volume
    }))

    const markers = getMarkers(data)
    console.log(markers)

    /**
     * Handle changing chart data (clear and reset)
     */
    if (this.lineSeries) {
      this.chartInstance.removeSeries(this.lineSeries)
      this.chartInstance.removeSeries(this.volumeSeries)
      this.lineSeries = null
      this.volumeSeries = null
    }

    /**
     * Creates series on persistent chart instance
     */
    this.lineSeries = this.chartInstance.addLineSeries();
    this.lineSeries.setData(chartData);
    this.lineSeries.setMarkers(markers)

    /**
     * Create custom volume histogram
     */
    this.volumeSeries = this.chartInstance.addHistogramSeries({
      priceFormat: {
        type: 'volume',
      },
      priceScaleId: '',
      scaleMargins: {
        top: 0.8,
        bottom: 0,
      },
    });

    this.volumeSeries.setData(volumeData)

    /**
     * Scale to constraints
     */
    this.chartInstance.timeScale().fitContent();
  },
  updated() {
    this.renderChart()
  }
}