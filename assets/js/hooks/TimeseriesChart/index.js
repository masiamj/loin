import { createChart, CrosshairMode, LineStyle } from 'lightweight-charts';

const currentLocale = window.navigator.languages[0];

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

    const chartData = data.map(({ close, date, trend } = {}) => ({
      color: getColorForItem({ trend }),
      time: date,
      value: close
    }))

    const volumeData = data.map(({ volume, date }) => ({
      color: 'rgba(37,99,235, 0.4)',
      time: date,
      value: volume
    }))

    if (this.lineSeries) {
      this.chartInstance.removeSeries(this.lineSeries)
      this.chartInstance.removeSeries(this.volumeSeries)
      this.lineSeries = null
      this.volumeSeries = null
    }

    this.lineSeries = this.chartInstance.addLineSeries();
    this.lineSeries.setData(chartData);
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
    this.chartInstance.timeScale().fitContent();
  },
  updated() {
    this.renderChart()
  }
}