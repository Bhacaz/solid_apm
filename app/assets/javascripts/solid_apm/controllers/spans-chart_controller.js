import {
  Controller,
} from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js";

// Connects to data-controller="spans-charts"
window.Stimulus.register('spans-chart',
  class extends Controller {
  static values = { id: String }

  connect() {
    console.log("Connected")
    const options = {
      series: [
        {
          data: []
        }
      ],
      chart: {
        type: "rangeBar",
        height: "250em",
      },
      plotOptions: {
        bar: {
          horizontal: true
        }
      },
      xaxis: {
        type: "datetime",
        labels: {
          show: false
        }
      },
      tooltip: {
        custom: function ({y1, y2,dataPointIndex, seriesIndex, w}) {
        // custom: function (opts) {
        //   console.log(opts)
          // console.log(value)
          return (
            '<div class="apexcharts-tooltip-title has-text-black" style="max-width: 40em; text-wrap: balance;">' +
            w.globals.initialSeries[seriesIndex].data[dataPointIndex].duration + "ms" +
            "<br>" +
            w.globals.initialSeries[seriesIndex].data[dataPointIndex].name +
            "<br>" +
            w.globals.initialSeries[seriesIndex].data[dataPointIndex].summary +
            '</div>'
          )
        }
      },
      yaxis: {
        labels: {
          formatter: function (value, opts) {
            if (opts === undefined) {
              return value[1] - value[0] + "ms"
            }
            if (opts.dataPointIndex >= 0) {
              return opts.w.globals.initialSeries[opts.seriesIndex].data[opts.dataPointIndex].name
            }
            return value
          }
        }
      },
    }

    fetch(this.idValue + "/spans.json")
      .then(response => response.json())
      .then(data => {
        options.series[0].data = data.map(d => {
          let startTime = new Date(d.timestamp).getTime()
          let endTime = new Date(d.end_time).getTime()
          if (endTime - startTime < 1) {
            endTime = startTime + 1
          }
          return {
            x: d.uuid,
            y: [startTime, endTime],
            name: d.name,
            summary: d.summary || d.name,
            duration: this.round(d.duration, 2)
          }
        })
        this.chart = new ApexCharts(this.element, options)
        this.chart.render()
      })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  round(num, decimalPlaces = 0) {
    num = Math.round(num + "e" + decimalPlaces);
    return Number(num + "e" + -decimalPlaces);
  }
})
