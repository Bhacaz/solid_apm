# frozen_string_literal: true

module SolidApm
  module Mcp
    class SpansForTransactionTool < FastMcp::Tool
      tool_name "spans-for-transaction"
      description "Returns spans for a specific transaction uuid in the APM system, with backtrace information and metadata"

      arguments do
        required(:transaction_uuid)
          .filled(:string)
          .description("The UUID of the transaction to retrieve spans for")
      end

      def call(transaction_uuid:)
        transaction = SolidApm::Transaction.find_by!(uuid: transaction_uuid)
        JSON.generate({
            transaction: transaction,
            spans: transaction.spans
                      }.as_json
        )
      rescue StandardError => e
        JSON.generate({
          error: e.message,
          backtrace: e.backtrace.first(5)
        }.as_json)
      end
    end
  end
end
