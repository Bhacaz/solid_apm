# frozen_string_literal: true

module SolidApm
  class TransactionsController < ApplicationController
    TransactionAggregation = Struct.new(:name, :tmp, :latency, :percentile_95, :impact)

    def index
      @aggregated_transactions = Transaction.where(created_at: 1.hour.ago..).group_by(&:name)
      @aggregated_transactions.transform_values! do |transactions|
        latency = transactions.map(&:duration).sum / transactions.size
        tmp = transactions.size.to_f / 60
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
        aggregation.impact = normalized_impact.to_i
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
                 .where(created_at: 1.hour.ago..)

      if params[:name].present?
        scope = scope.where(name: params[:name])
      end

      render json: scope.group_by { |t| t.created_at.beginning_of_minute }
           .transform_values!(&:count)
    end
  end
end
