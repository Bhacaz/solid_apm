# frozen_string_literal: true

# ActiveSupport::Notifications.subscribe(/.*/) do |name, start, finish, id, payload|
#   pp name unless name.start_with?("!")
#   pp payload.first(3) unless name.start_with?("!")
# end

ActiveSupport::Notifications.subscribe("start_processing.action_controller") do |name, start, finish, id, payload|
  SpanSubscriber::Base.transaction = Transaction.new(
    uuid: SecureRandom.uuid,
    timestamp: Time.current,
    type: 'request',
    name: "#{payload[:controller]}##{payload[:action]}",
    metadata: { params: payload[:request].params.except(:controller, :action) }
  )
  SpanSubscriber::Base.spans = []
end

ActiveSupport::Notifications.subscribe("process_action.action_controller") do |name, start, finish, id, payload|
  transaction = SpanSubscriber::Base.transaction
  transaction.end_time = Time.current
  transaction.duration = (transaction.end_time.to_f - transaction.timestamp.to_f).round(6)
  SpanSubscriber::Base.transaction = nil
  ApplicationRecord.transaction do
    transaction.save!

    SpanSubscriber::Base.spans.each do |span|
      # Span.new(**span, related_transaction: transaction)
      span[:transaction_id] = transaction.id
    end
    Span.insert_all SpanSubscriber::Base.spans
  end
  SpanSubscriber::Base.spans = nil
end

ActiveSupport.on_load(:action_controller) do
  # SpanSubscriber::Base.subscribe!
  SpanSubscriber::ActionView.subscribe
  SpanSubscriber::SqlActiveRecord.subscribe


end
