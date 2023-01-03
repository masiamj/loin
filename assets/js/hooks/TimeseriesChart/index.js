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
      return 'yellow'
  }
}

export const TimeseriesChart = {
  getTimeseriesData() {
    const serializedData = this.el.dataset.timeseries || '[]'
    const deserializedData = JSON.parse(serializedData)
    return deserializedData
  },
  mounted() {
    console.log('TimeseriesChart hook mounted')
    this.chartInstance = createChart(this.el)

    const data = this.getTimeseriesData()

    const chartData = data.map(({ close, date, trend } = {}) => ({
      color: getColorForItem({ trend }),
      time: date,
      value: close
    }))

    const lineSeries = this.chartInstance.addLineSeries();

    lineSeries.setData(chartData);

    this.chartInstance.timeScale().fitContent();
  }
}