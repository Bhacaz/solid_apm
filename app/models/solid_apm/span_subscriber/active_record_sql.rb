# frozen_string_literal: true
module SolidApm
  module SpanSubscriber
    class ActiveRecordSql < Base
      PATTERN = "sql.active_record"

      def summary(payload)
        payload[:sql]
      end
    end
  end
end
