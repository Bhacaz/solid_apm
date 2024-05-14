class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.all.order(timestamp: :desc).limit(10)
    respond_to do |format|
      format.html
      format.json { render json: transactions_count_by_minutes }
    end
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def spans
    @transaction = Transaction.find(params[:id])
    @spans = @transaction.spans
    render json: @spans
  end

  private

  def transactions_count_by_minutes
    Transaction.all.order(timestamp: :desc)
               .where(created_at: 1.hour.ago..)
               .group_by { |t| t.created_at.beginning_of_minute }
               .transform_values!(&:count)
  end
end
