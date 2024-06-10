import {
  Controller,
} from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js";
// unload chart https://github.com/Deanout/weight_tracker/blob/d4123acb952d91fcc9bedb96bbd786088a71482a/app/javascript/controllers/weights_controller.js#L4
// tooltip: {
//   y: {
//     formatter: function (value, {series, seriesIndex, dataPointIndex, w}) {
//       return w.globals.initialSeries[seriesIndex].data[dataPointIndex].name + "\n" + value + "ms"
//     }
//   }
// }

// Connects to data-controller="transaction-chart"
window.Stimulus.register('transaction-chart',
  class extends Controller {
  connect() {
    console.log('Connected')
    var options = {
      chart: {
        type: 'bar',
        height: '200em'
      },
      series: [{
        name: 'Duration',
      }],
      xaxis: {
        type: 'datetime'
      },
      tooltip: {
        x: {
          formatter: function (value) {
            return new Date(value).toLocaleString()
          }
        }
      }
    }
    fetch('transactions.json')
      .then(response => response.json())
      .then(data => {
        const transformedData = []
        for (let [key, value] of Object.entries(data)) {
          transformedData.push({x: key, y: value})
        }
        options.series[0].data = transformedData
        this.chart = new ApexCharts(this.element, options)
        this.chart.render()
      })
  }

  // Unloads the chart before loading new data.
  disconnect() {
    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
  }
})
