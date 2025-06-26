# frozen_string_literal: true

module SolidApm
  module Mcp
    class SpansMcpTool < ApplicationTool
      tool_name "longest-spans-for-transaction"
      description "Returns longest spans for a specific transaction uuid in the APM system, with backtrace information and metadata"

      arguments do
        required(:transaction_uuid).filled(:string).description("The UUID of the transaction to retrieve spans for")
      end

      def call(transaction_uuid:)
        spans = SolidApm::Span.joins(:related_transaction)
                              .merge(SolidApm::Transaction.where(uuid: transaction_uuid))
                              .where(created_at: 24.hours.ago..)
                              .order(duration: :desc)
                              .limit(5)
        JSON.generate(spans.as_json)
      end
    end
  end
end