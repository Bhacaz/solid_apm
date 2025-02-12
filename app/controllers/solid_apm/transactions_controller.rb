# frozen_string_literal: true

module SolidApm
  class TransactionsController < ApplicationController
    TransactionAggregation = Struct.new(:name, :tmp, :latency, :percentile_95, :impact)

    def index
      if from_to_range.end < from_to_range.begin
        flash[:error] = 'Invalid time range'
        redirect_to transactions_path
        return
      end
      @aggregated_transactions = Transaction.where(created_at: from_to_range).group_by(&:name)
      @aggregated_transactions.transform_values! do |transactions|
        latency = transactions.map(&:duration).sum / transactions.size
        tmp = transactions.size.to_f / ((from_to_range.end - from_to_range.begin) / 60).to_i
        impact = latency * tmp
        percentile_95 = transactions[transactions.size * 0.95].duration
        TransactionAggregation.new(
          transactions.first.name,
          tmp,
          latency,
          percentile_95,
          impact
        )
      end
      if @aggregated_transactions.empty?
        return
      end
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
    end

    def show_by_name
      @transactions = Transaction.where(name: params[:name]).order(timestamp: :desc).limit(20)
    end

    def show
      @transaction = Transaction.find(params[:id])
    end

    def spans
      @transaction = Transaction.find(params[:id])
      @spans = @transaction.spans
      render json: @spans
    end

    def count_time_aggregations
      scope = Transaction.order(timestamp: :desc)
                 .where(created_at: from_to_range)

      if params[:name].present?
        scope = scope.where(name: params[:name])
      end

      # Maybe only extract what I need from Groupdate so I dont depend on it.
      render json: scope.group_by_second(:created_at, n: n_intervals_seconds(from_to_range)).count
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

    def n_intervals_seconds(range, intervals_count: 20)
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
