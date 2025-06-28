# frozen_string_literal: true

module SolidApm
  module Mcp
    class ImpactfulTransactionsResource < FastMcp::Resource
      uri "solid-apm://impactful-transactions"
      resource_name "impactful_transactions"
      mime_type "application/json"
      description "Returns the most impactful transactions with comprehensive performance metrics"

    def content
      transactions_with_impact = calculate_impactful_transactions

      result = {
        metadata: {
          total_transactions_analyzed: SolidApm::Transaction.where(timestamp: 24.hours.ago..).count,
          analysis_period: "last 24 hours",
          impact_score_explanation: "Calculated based on P95 latency, transaction frequency, span complexity, and error rate"
        },
        transactions: transactions_with_impact.map do |transaction_data|
          {
            id: transaction_data[:transaction].id,
            uuid: transaction_data[:transaction].uuid,
            name: transaction_data[:transaction].name,
            type: transaction_data[:transaction].type,
            impact_score: transaction_data[:impact_score],
            metrics: {
              p95_latency_ms: transaction_data[:p95_latency],
              avg_duration_ms: transaction_data[:avg_duration],
              max_duration_ms: transaction_data[:max_duration],
              transactions_per_minute: transaction_data[:tpm],
              max_transactions_per_minute: transaction_data[:max_tpm],
              avg_spans_per_transaction: transaction_data[:avg_spans],
              max_spans_per_transaction: transaction_data[:max_spans],
              total_occurrences: transaction_data[:total_count],
            },
            sample_transaction: {
              uuid: transaction_data[:sample_transaction]&.uuid,
              duration_ms: transaction_data[:sample_transaction]&.duration,
              span_count: transaction_data[:sample_span_count],
              timestamp: transaction_data[:sample_transaction]&.timestamp
            }
          }
        end
        }

        JSON.generate(result)
      rescue StandardError => e
        JSON.generate({ error: e.message, backtrace: e.backtrace.first(5) })
      end

      private

      def calculate_impactful_transactions
        # Get transactions from last 24 hours for more relevant data
        cutoff_time = 24.hours.ago

        # Group transactions by name and type to aggregate metrics
        transaction_groups = SolidApm::Transaction.includes(:spans).where(timestamp: cutoff_time..).group_by { |t| [t.name, t.type] }

        impact_data = transaction_groups.map do |group_key, transactions| name, type = group_key
        durations = transactions.map(&:duration).compact
        span_counts = transactions.map { |t| t.spans.size }

        next if durations.empty?

        # Calculate P95 latency
        p95_latency = calculate_percentile(durations, 95)
        avg_duration = durations.sum / durations.size.to_f
        max_duration = durations.max

        # Calculate transaction frequency metrics
        total_count = transactions.size
        time_span_hours = [(Time.current - transactions.map(&:timestamp).min) / 1.hour, 1].max
        tpm = (total_count / (time_span_hours * 60)).round(2)

        # Calculate max TPM by looking at busiest minute
        max_tpm = calculate_max_tpm(transactions)

        # Span complexity metrics
        avg_spans = span_counts.sum / span_counts.size.to_f
        max_spans = span_counts.max || 0

        # Get a representative sample transaction
        sample_transaction = transactions.max_by(&:duration)
        sample_span_count = sample_transaction&.spans&.size || 0

        {
          transaction: transactions.first, # Representative transaction for metadata
          p95_latency: p95_latency.round(2),
          avg_duration: avg_duration.round(2),
          max_duration: max_duration.round(2),
          tpm: tpm,
          max_tpm: max_tpm,
          avg_spans: avg_spans.round(1),
          max_spans: max_spans,
          total_count: total_count,
          sample_transaction: sample_transaction,
          sample_span_count: sample_span_count
        }
        end.compact

        # Sort by impact score and return top 10
        impact_data.sort_by { |data| -data[:impact_score] }.first(10)
      end

      def calculate_percentile(array, percentile)
        return 0 if array.empty?

        sorted = array.sort
        index = (percentile / 100.0) * (sorted.length - 1)

        if index == index.to_i
          sorted[index.to_i]
        else lower = sorted[index.floor]
        upper = sorted[index.ceil]
        lower + (upper - lower) * (index - index.floor)
        end
      end

      def calculate_max_tpm(transactions)
        return 0 if transactions.empty?

        # Group by minute and find the busiest minute
        minute_counts = transactions.group_by { |t| t.timestamp.beginning_of_minute }.values.map(&:size)
        minute_counts.max || 0
      end

      def calculate_impact_score(p95_latency:, tpm:, avg_spans:, total_count:)
        # Weighted impact score calculation
        # Higher scores indicate more impactful transactions

        latency_score = Math.log([p95_latency, 1].max) * 20 # Log scale for latency
        frequency_score = Math.log([tpm, 1].max) * 30 # Log scale for frequency
        complexity_score = Math.log([avg_spans, 1].max) * 15 # Span complexity
        volume_score = Math.log([total_count, 1].max) * 10 # Total volume

        (latency_score + frequency_score + complexity_score + volume_score).round(2)
      end
    end
  end
end