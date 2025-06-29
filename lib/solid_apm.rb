require 'English' # For apexcharts Regex
require 'groupdate'
require 'active_median'
require 'apexcharts'

require "solid_apm/version"
require "solid_apm/engine"
require "solid_apm/sampler"

module SolidApm
  mattr_accessor :connects_to
  mattr_accessor :mcp_server_config, default: {}
  mattr_accessor :silence_active_record_logger, default: true
  mattr_accessor :transaction_sampling, default: 1
  mattr_accessor(
    :transaction_filters, default: [
      /^SolidApm::/,
      /^ActionDispatch::Request::PASS_NOT_FOUND/,
      'Rails::HealthController#show'
    ]
  )

  def self.set_context(context)
    SpanSubscriber::Base.context = context
  end
end
