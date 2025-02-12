# frozen_string_literal: true

module SolidApm
  module SpanSubscriber
    class ActionDispatch < Base
      PATTERN = /\w+\.action_dispatch/.freeze
      def self.subscribe
        super do |name, start, finish, id, payload|
          transaction = SpanSubscriber::Base.transaction
          transaction.name = "#{payload[:request].controller_class}##{payload[:request].path_parameters[:action]}"
          transaction.end_time = finish
          transaction.duration = ((transaction.end_time.to_f - transaction.timestamp.to_f) * 1000).round(6)
          transaction.metadata = {
            params: payload[:request].params.except(:controller, :action),
            context: SpanSubscriber::Base.context
          }
          SpanSubscriber::Base.context = {}
        end
      end

      def summary(payload)
        "#{payload[:request].controller_class}##{payload[:request].path_parameters[:action]}"
      end
    end
  end
end
