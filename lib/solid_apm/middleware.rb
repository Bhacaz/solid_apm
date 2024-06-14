# frozen_string_literal: true

module SolidApm
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      transaction = SpanSubscriber::Base.transaction

      # Skip if the transaction is not from SolidApm
      if transaction && !transaction.name.start_with?('SolidApm::')
        env['rack.after_reply'] ||= []
        env['rack.after_reply'] << ->() do
          self.class.call
        rescue StandardError => e
          Rails.logger.error e
          Rails.logger.error e.backtrace&.join("\n")
        end
      end

      @app.call(env)
    end

    def self.call
      transaction = SpanSubscriber::Base.transaction
      SpanSubscriber::Base.transaction = nil

      ApplicationRecord.transaction do
        transaction.save!

        SpanSubscriber::Base.spans.each do |span|
          span[:transaction_id] = transaction.id
        end
        SolidApm::Span.insert_all SpanSubscriber::Base.spans
      end
      SpanSubscriber::Base.spans = nil
    end
  end
end
