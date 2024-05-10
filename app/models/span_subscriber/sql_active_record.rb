# frozen_string_literal: true

module SpanSubscriber
  class SqlActiveRecord < Base
    PATTERN = "sql.active_record"

    def summary(payload)
      payload[:sql]
    end
  end
end
