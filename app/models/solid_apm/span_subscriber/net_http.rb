# frozen_string_literal: true

require 'net/http'
module SolidApm
module SpanSubscriber
  class NetHttp < Base
    PATTERN = 'request.net_http'

    def summary(payload)
      payload
    end

    def self.subscribe
      if defined?(::Net::HTTP)
        ::Net::HTTP.prepend(NetHttpInstrumentationPrepend)
        super
      end
    end

    # https://github.com/scoutapp/scout_apm_ruby/blob/3838109214503755c5cbd4caf78f6446adbe222f/lib/scout_apm/instruments/net_http.rb#L61
    module NetHttpInstrumentationPrepend
      def request(request, *args, &block)
        ActiveSupport::Notifications.instrument PATTERN, request_solid_apm_description(request) do
          super(request, *args, &block)
        end
      end

      def request_solid_apm_description(req)
        path = req.path
        path = path.path if path.respond_to?(:path)

        # Protect against a nil address value
        if @address.nil?
          return "No Address Found"
        end

        max_length = 500
        req.method.upcase + " " + (@address + path.split('?').first)[0..(max_length - 1)]
      rescue
        ""
      end
    end
  end
end
end
