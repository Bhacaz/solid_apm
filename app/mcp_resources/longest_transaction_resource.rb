# frozen_string_literal: true

module SolidApm
  class LongestTransactionResource < ApplicationMcpResource
    uri "solid-apm://longest-transaction"
    resource_name "longest_transaction"
    mime_type "application/json"
    description "Returns the longest transaction in the APM system"

    def content
      longest_transaction = SolidApm::Transaction.order(duration: :desc).first
      if longest_transaction
        JSON.generate(longest_transaction.as_json)
      else
        JSON.generate({ error: "No traces found" })
      end
    rescue StandardError => e
      JSON.generate({ error: e.message })
    end
  end
end
