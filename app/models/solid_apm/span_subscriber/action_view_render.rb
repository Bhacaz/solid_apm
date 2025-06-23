# frozen_string_literal: true

module SolidApm
  module SpanSubscriber
    class ActionViewRender < Base
      PATTERN = /^render_.+\.action_view/

      def summary(payload)
        identifier = payload[:identifier]
        clean_trace(identifier)
      end
    end
  end
end
