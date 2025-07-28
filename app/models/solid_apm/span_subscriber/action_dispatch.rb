# frozen_string_literal: true

module SolidApm
  module SpanSubscriber
    class ActionDispatch < Base
      PATTERN = 'request.action_dispatch'
      def self.subscribe
        super do |name, start, finish, id, payload|
          transaction = SpanSubscriber::Base.transaction
          transaction.name = "#{payload[:request].controller_class}##{payload[:request].path_parameters[:action]}"
          transaction.timestamp = start
          transaction.end_time = finish
          transaction.duration = ((finish.to_f - start.to_f) * 1000).round(6)
          transaction.metadata = {
            params: payload[:request].params.except(:controller, :action),
            context: SpanSubscriber::Base.context || {}
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
