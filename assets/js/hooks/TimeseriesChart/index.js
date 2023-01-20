import { createChart } from 'lightweight-charts';

const getColorForItem = ({ trend } = {}) => {
  switch (trend) {
    case null:
      return 'grey'
    case 'up':
      return 'green'
    case 'down':
      return 'red'
    case 'neutral':
      return 'gray'
  }
}

export const TimeseriesChart = {
  createChart() {
    this.chartInstance = createChart(this.el)
  },
  getTimeseriesData() {
    const serializedData = this.el.dataset.timeseries || '[]'
    const deserializedData = JSON.parse(serializedData)
    return deserializedData
  },
  mounted() {
    this.createChart()
    this.renderChart()
    console.log(this.lineSeries)
  },
  renderChart() {
    const data = this.getTimeseriesData()
    const chartData = data.map(({ close, date, trend } = {}) => ({
      color: getColorForItem({ trend }),
      time: date,
      value: close
    }))

    if (this.lineSeries) {
      this.chartInstance.removeSeries(this.lineSeries)
      this.lineSeries = null
    }

    this.lineSeries = this.chartInstance.addLineSeries();
    this.lineSeries.setData(chartData);
    this.chartInstance.timeScale().fitContent();
  },
  updated() {
    this.renderChart()
  }
}