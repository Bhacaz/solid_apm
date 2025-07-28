# frozen_string_literal: true

module SolidApm
  module SpanSubscriber
    class ActiveJob < Base
      PATTERN = /\Aperform\.active_job\z/

      def summary(payload)
        {
          job_class: payload[:job].class.name,
          queue_name: payload[:job].queue_name,
          job_id: payload[:job].job_id,
          arguments: payload[:job].arguments
        }
      end
    end
  end
end
