require_relative './middleware'

module SolidApm
  class Engine < ::Rails::Engine
    isolate_namespace SolidApm

    config.app_middleware.use Middleware
    # config.before_configuration do
    # end

    config.after_initialize do
      # Rails.autoloaders.main.eager_load_dir('app/models/span_subscriber')

      ActiveSupport::Notifications.subscribe("start_processing.action_controller") do |name, start, finish, id, payload|
        SpanSubscriber::Base.transaction = Transaction.new(
          uuid: SecureRandom.uuid,
          timestamp: start,
          type: 'request',
          name: "#{payload[:controller]}##{payload[:action]}",
          metadata: { params: payload[:request].params.except(:controller, :action) }
        )
        SpanSubscriber::Base.spans = []
      end

      ActiveSupport::Notifications.subscribe("process_action.action_controller") do |name, start, finish, id, payload|
        # Set the end time and duration of the transaction with the process_action event
        transaction = SpanSubscriber::Base.transaction
        transaction.end_time = finish
        transaction.duration = ((transaction.end_time.to_f - transaction.timestamp.to_f) * 1000).round(6)
      end

      SpanSubscriber::Base.subscribe!
    end
  end
end
