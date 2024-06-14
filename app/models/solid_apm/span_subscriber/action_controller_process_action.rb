# frozen_string_literal: true

module SolidApm
  module SpanSubscriber
    class ActionControllerProcessAction < Base
      PATTERN = 'process_action.action_controller'

      def summary(payload)
        "#{payload[:controller]}##{payload[:action]}"
      end

      def self.subscribe
        super do |name, start, finish, id, payload|
          # Set the end time and duration of the transaction with the process_action event
          transaction = SpanSubscriber::Base.transaction
          transaction.end_time = finish
          transaction.duration = ((transaction.end_time.to_f - transaction.timestamp.to_f) * 1000).round(6)
        end
      end
    end
  end
end
