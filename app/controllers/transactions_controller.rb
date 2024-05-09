class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.all.order(timestamp: :desc).limit(10)
  end

  def show
    @transaction = Transaction.find(params[:id])
  end
end
