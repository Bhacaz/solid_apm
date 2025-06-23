# frozen_string_literal: true
module SolidApm
  module SpanSubscriber
    class ActiveRecordSql < Base
      PATTERN = /^(sql|transaction)\.active_record/.freeze

      def summary(payload)
        payload[:sql]
      end
    end
  end
end
