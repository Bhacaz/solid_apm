import {Controller} from "@hotwired/stimulus"
import ApexCharts from 'apexcharts'

// Connects to data-controller="transaction-chart"
export default class extends Controller {
  connect() {
    var options = {
      chart: {
        type: 'line'
      },
      series: [{
        name: 'Duration',
      }],
      xaxis: {
        type: 'datetime'
      },
      tooltip: {
        y: {
          formatter: function (value, {series, seriesIndex, dataPointIndex, w}) {
            return w.globals.initialSeries[seriesIndex].data[dataPointIndex].name + "\n" + value + "ms"
          }
        }
      }
    }
    fetch('/transactions.json')
      .then(response => response.json())
      .then(data => {
        options.series[0].data = data.map(d => {
          return {x: d.timestamp, y: d.duration, name: d.name}
        })
        const chart = new ApexCharts(this.element, options)
        chart.render()
      })

  }
}
