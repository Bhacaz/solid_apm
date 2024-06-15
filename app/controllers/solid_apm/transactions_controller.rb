# frozen_string_literal: true

module SolidApm
  class TransactionsController < ApplicationController
    TransactionAggregation = Struct.new(:name, :tmp, :latency, :percentile_95, :impact)

    def index
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

    def count_by_minutes
      scope = Transaction.all.order(timestamp: :desc)
                 .where(created_at: from_to_range)

      if params[:name].present?
        scope = scope.where(name: params[:name])
      end

      render json: scope.group_by { |t| t.created_at.beginning_of_minute }
           .transform_values!(&:count)
    end

    private

    def from_to_range
      params[:from_value] ||= 60
      params[:from_unit] ||= 'minutes'
      from = params[:from_value].to_i.public_send(params[:from_unit].to_sym).ago
      to = Time.current
      (from..to)
    end
  end
end
