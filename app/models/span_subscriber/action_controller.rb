# frozen_string_literal: true

module SpanSubscriber
  class ActionController < Base
    PATTERN = 'process_action.action_controller'

    def summary(payload)
      "#{payload[:controller]}##{payload[:action]}"
    end
  end
end
