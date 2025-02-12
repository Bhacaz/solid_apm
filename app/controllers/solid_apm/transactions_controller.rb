# frozen_string_literal: true

module SolidApm
  class TransactionsController < ApplicationController
    TransactionAggregation = Struct.new(:name, :tmp, :latency, :percentile_95, :impact)
    private_constant :TransactionAggregation

    def index
      if from_to_range.end < from_to_range.begin
        flash[:error] = 'Invalid time range'
        redirect_to transactions_path
        return
      end

      @transactions_scope = Transaction.where(timestamp: from_to_range)
      if params[:name].present?
        @transactions_scope = @transactions_scope.where(name: params[:name])
      end
      transaction_names = @transactions_scope.distinct.pluck(:name)
      latency_95p = @transactions_scope.group(:name).percentile(:duration, 0.95)
      latency_median = @transactions_scope.group(:name).median(:duration)
      tmp_dict = @transactions_scope.group(:name).group_by_minute(:timestamp, series: false).count.each_with_object({}) do |(k, v), h|
        current_value = h[k.first] ||= 0
        h[k.first] = v if v > current_value
      end

      @aggregated_transactions = transaction_names.each_with_object({}) do |transaction_name, h|
        latency = latency_median[transaction_name]
        tmp = tmp_dict[transaction_name]
        impact = latency * tmp
        h[transaction_name] = TransactionAggregation.new(
          transaction_name,
          tmp,
          latency,
          latency_95p[transaction_name],
          impact
        )
      end

      return if @aggregated_transactions.empty?
      # Find the maximum and minimum impact values
      max_impact = @aggregated_transactions.values.max_by(&:impact).impact
      min_impact = @aggregated_transactions.values.min_by(&:impact).impact

      # Normalize impact 0-100
      @aggregated_transactions.each do |_, aggregation|
        normalized_impact = ((aggregation.impact - min_impact) / (max_impact - min_impact)) * 100
        normalized_impact = 0 if normalized_impact.nan?
        aggregation.impact = normalized_impact.to_i || 0
      end
      @aggregated_transactions = @aggregated_transactions.sort_by { |_, v| -v.impact }.to_h

      scope = @transactions_scope.group_by_second(:timestamp, n: n_intervals_seconds(from_to_range))
      @throughput_data = scope.count
      @latency_data = scope.median(:duration).transform_values(&:to_i)
    end

    def spans
      @transaction = Transaction.find_by!(uuid: params[:uuid])
      @transaction.spans.to_a
    end

    private

    def from_to_range
      params[:from_value] ||= 60
      params[:from_unit] ||= 'minutes'
      from = params[:from_value].to_i.public_send(params[:from_unit].to_sym).ago
      params[:to_value] ||= 1
      params[:to_unit] ||= 'seconds'
      to = params[:to_value].to_i.public_send(params[:to_unit].to_sym).ago
      (from..to)
    end

    def n_intervals_seconds(range, intervals_count: 30)
      start_time = range.begin
      end_time = range.end
      time_range_in_seconds = (end_time - start_time).to_i
      (time_range_in_seconds / intervals_count.to_f).round
    end

    def aggregate(items, range, intervals_count: 20)
      start_time = range.begin
      end_time = range.end
      time_range_in_seconds = (end_time - start_time).to_i
      time_interval_duration_in_seconds = (time_range_in_seconds / intervals_count.to_f).round

      items.chunk { |item| Time.zone.at((item.created_at.to_i) / time_interval_duration_in_seconds * time_interval_duration_in_seconds, 0) }.to_h
    end
  end
end
