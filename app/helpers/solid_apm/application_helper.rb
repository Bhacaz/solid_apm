module SolidApm
  module ApplicationHelper
    def area_chart_options
      {
        module: true,
        chart: {
          type: 'area', height: '200', background: '0', foreColor: '#ffffff55', zoom: {
            enabled: false,
          }, toolbar: {
            show: false,
          }
        },
        xaxis: {
        type: 'datetime',
        tooltip: {
          enabled: false

        }
      },
        stroke: {
        curve: 'smooth'
      }, theme: {
        mode: 'dark',
      }, grid: {
        show: true, borderColor: '#ffffff55',
      }, dataLabels: {
        enabled: false
      },
       tooltip: {x: {formatter: {function: {args: "val", body: "return new Date(val).toLocaleString()"}} }}
      }
    end
  end
end
