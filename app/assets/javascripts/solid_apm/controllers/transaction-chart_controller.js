import {Controller,} from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js";
// unload chart https://github.com/Deanout/weight_tracker/blob/d4123acb952d91fcc9bedb96bbd786088a71482a/app/javascript/controllers/weights_controller.js#L4
// tooltip: {
//   y: {
//     formatter: function (value, {series, seriesIndex, dataPointIndex, w}) {
//       return w.globals.initialSeries[seriesIndex].data[dataPointIndex].name + "\n" + value + "ms"
//     }
//   }
// }

// Connects to data-controller="transaction-chart"
window.Stimulus.register('transaction-chart', class extends Controller {
  static values = {name: String, data: Array, color: String}

  connect() {
    var options = {
      colors: [this.colorValue],
      chart: {
        type: 'area', height: '200em', background: '0', foreColor: '#ffffff55', zoom: {
          enabled: false,
        }, toolbar: {
          show: false,
        }
      }, series: [{
        name: this.nameValue, data: this.dataValue
      }], xaxis: {
        type: 'datetime'
      }, stroke: {
        curve: 'smooth'
      }, theme: {
        mode: 'dark',
      }, grid: {
        show: true, borderColor: '#ffffff55',
      }, dataLabels: {
        enabled: false
      }, tooltip: {
        x: {
          formatter: function (value) {
            return new Date(value).toLocaleString()
          }
        }
      }
    }

    this.chart = new ApexCharts(this.element, options)
    this.chart.render()
  }

  // Unloads the chart before loading new data.
  disconnect() {
    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
  }
})
