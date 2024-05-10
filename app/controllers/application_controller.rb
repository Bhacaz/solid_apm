class ApplicationController < ActionController::Base
  thread_cattr_accessor :transaction
  thread_cattr_accessor :spans

  before_action do
    params = request.params.except(:controller, :action).to_json
    ApplicationController.transaction = Transaction.new(
      uuid: SecureRandom.uuid,
      timestamp: Time.current,
      type: 'request',
      name: "#{controller_name}##{action_name}",
      metadata: { params: params }
    )
    ApplicationController.spans = []
  end

  after_action do
    transaction = ApplicationController.transaction
    transaction.end_time = Time.current
    transaction.duration = (transaction.end_time.to_f - transaction.timestamp.to_f).round(6)
    ApplicationController.transaction = nil
    ApplicationRecord.transaction do
      transaction.save!

      ApplicationController.spans.each do |span|
        # Span.new(**span, related_transaction: transaction)
        span[:transaction_id] = transaction.id
      end
      Span.insert_all ApplicationController.spans
    end
  end
end
