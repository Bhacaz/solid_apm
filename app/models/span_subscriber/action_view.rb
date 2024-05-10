# frozen_string_literal: true

module SpanSubscriber
  class ActionView < Base
    PATTERN = /^\w+\.action_view/

    def summary(payload)
      identifier = payload[:identifier]
      identifier.sub(Rails.root.to_s + '/', '')
    end
  end
end
