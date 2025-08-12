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

    def area_chart_options(browser_timezone: nil)
      timezone_js = if browser_timezone.present?
                      "if (!val) return ''; return new Date(val).toLocaleString('en-US', { timeZone: '#{browser_timezone}', hour12: false })"
                    else
                      "if (!val) return ''; return new Date(val).toLocaleString('en-US', { hour12: false })"
                    end

      # Create date formatter for x-axis labels that respects timezone
      xaxis_formatter = if browser_timezone.present?
                          "if (!val) return ''; return new Date(val).toLocaleString('en-US', { timeZone: '#{browser_timezone}', hour: '2-digit', minute: '2-digit', day: '2-digit', month: 'short', hour12: false })"
                        else
                          "if (!val) return ''; return new Date(val).toLocaleString('en-US', { hour: '2-digit', minute: '2-digit', day: '2-digit', month: 'short', hour12: false })"
                        end

      {
        module: true,
        chart: {
          type: 'area',
          height: '200',
          background: '0',
          foreColor: '#ffffff55',
          zoom: {
            enabled: true,
            autoScaleYaxis: true
          },
          selection: {
            enabled: true,
            type: 'x'
          },
          toolbar: {
            show: false
          },
          events: {
            zoomed: {
              function: {
                args: 'chartContext, { xaxis, yaxis }',
                body: 'handleChartSelection(xaxis.min, xaxis.max)'
              }
            },
            selection: {
              function: {
                args: 'chartContext, { xaxis, yaxis }',
                body: 'handleChartSelection(xaxis.min, xaxis.max)'
              }
            }
          }
        },
        xaxis: {
          type: 'datetime',
          tooltip: {
            enabled: false
          },
          labels: {
            formatter: {
              function: {
                args: 'val',
                body: xaxis_formatter
              }
            }
          }
        },
        stroke: {
          curve: 'smooth'
        },
        theme: {
          mode: 'dark'
        },
        grid: {
          show: true,
          borderColor: '#ffffff55'
        },
        dataLabels: {
          enabled: false
        },
        tooltip: {
          x: {
            formatter: {
              function: {
                args: 'val',
                body: timezone_js
              }
            }
          }
        }
      }
    end
  end
end
