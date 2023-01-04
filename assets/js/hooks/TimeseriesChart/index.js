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
    console.log(data)

    const chartData = data.map(({ close, date, trend } = {}) => ({
      color: getColorForItem({ trend }),
      time: date,
      value: close
    }))

    const markers = data.reduce((acc, item) => {
      const { date, trend_change } = item
      if (trend_change) {
        console.log(item)
      }
      if (trend_change === 'neutral_to_up') {
        acc.push({
          time: date,
          position: 'aboveBar',
          color: 'green',
          shape: 'circle',
          text: 'Entry',
        })
      } else if (trend_change === 'up_to_neutral') {
        acc.push({
          time: date,
          position: 'belowBar',
          color: 'red',
          shape: 'square',
          text: 'Exit',
        })
      }
      return acc
    }, [])

    const lineSeries = this.chartInstance.addLineSeries();

    lineSeries.setData(chartData);
    lineSeries.setMarkers(markers)

    this.chartInstance.timeScale().fitContent();
  }
}