module SolidApm
  module ApplicationHelper
    def span_type_color(span)
      case span.type
      when 'action_view'
        '#00bcd4cc' # cyan
      when 'action_dispatch'
        '#4caf50cc' # green
      when 'active_record'
        '#ff9800cc' # orange
      when 'active_support'
        '#f44336cc' # red
      when 'net_http'
        '#9c27b0cc' # purple
      when 'custom'
        '#3f51b5cc' # indigo
      else
        '#9e9e9ecc' # grey
      end
    end

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
