# frozen_string_literal: true

module SolidApm
class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      env['rack.after_reply'] ||= []
      env['rack.after_reply'] << ->() do
        self.class.call
      rescue StandardError => e
        Rails.logger.error e
        Rails.logger.error e.backtrace&.join("\n")
      end

      @app.call(env)
    end

    def self.call
      transaction = SpanSubscriber::Base.transaction
      return unless transaction

      SpanSubscriber::Base.transaction = nil
      ApplicationRecord.transaction do
        transaction.save!

        SpanSubscriber::Base.spans.each do |span|
          span[:transaction_id] = transaction.id
        end
        Span.insert_all SpanSubscriber::Base.spans
      end
      SpanSubscriber::Base.spans = nil
    end
  end
end
