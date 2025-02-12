import {Controller,} from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js";

// Connects to data-controller="transaction-chart"
window.Stimulus.register('transaction-chart', class extends Controller {
  static values = {name: String, data: Array, color: String}

  connect() {
    var options = {
      colors: [this.colorValue],
      chart: {
        type: 'area', height: '200', background: '0', foreColor: '#ffffff55', zoom: {
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
