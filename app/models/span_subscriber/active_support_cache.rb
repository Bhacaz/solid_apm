# frozen_string_literal: true

module SpanSubscriber
  class ActiveSupportCache < Base
    PATTERN = /^cache_.+.active_support/

    def summary(payload)
      payload[:key]
    end
  end
end
