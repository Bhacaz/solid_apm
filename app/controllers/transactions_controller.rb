class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.all.order(timestamp: :desc).limit(10)
    respond_to do |format|
      format.html
      format.json { render json: Transaction.all.order(timestamp: :desc).limit(30) }
    end
  end

  def show
    @transaction = Transaction.find(params[:id])
  end
end
