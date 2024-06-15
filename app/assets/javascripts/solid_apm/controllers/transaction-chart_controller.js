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
    static values = { name: String }

    connect() {
    console.log('Connected')
    var options = {
      chart: {
        type: 'bar',
        height: '200em'
      },
      series: [{
        name: 'tpm',
      }],
      xaxis: {
        type: 'datetime'
      },
      dataLabels: {
        enabled: false
      },
      tooltip: {
        x: {
          formatter: function (value) {
            return new Date(value).toLocaleString()
          }
        }
      }
    }

    let path = window.location.pathname.includes('transactions') ? 'count_by_minutes' : 'transactions/count_by_minutes';
    path = path + "?";
    if (this.nameValue) {
      path = path + "name=" + encodeURIComponent(this.nameValue);
    }

    const fromValue = document.querySelector('input[name="from_value"]')
    const fromUnit = document.querySelector('select[name="from_unit"]');
    if (fromValue && fromUnit) {
      path = path + "&from_value=" + fromValue.value + "&from_unit=" + fromUnit.value;
    }

    fetch(path)
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
