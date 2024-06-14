# frozen_string_literal: true

module SolidApm
  module SpanSubscriber
    class ActionControllerStartProcessing < Base
      PATTERN = 'start_processing.action_controller'
      def self.subscribe
        ActiveSupport::Notifications.subscribe(PATTERN) do |name, start, finish, id, payload|
          SpanSubscriber::Base.transaction = Transaction.new(
            uuid: SecureRandom.uuid,
            timestamp: start,
            type: 'request',
            name: "#{payload[:controller]}##{payload[:action]}",
            metadata: { params: payload[:request].params.except(:controller, :action) }
          )
          SpanSubscriber::Base.spans = []
        end
      end
    end
  end
end