# frozen_string_literal: true

module SolidApm
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      self.class.init_transaction
      status, headers, body = @app.call(env)

        env['rack.after_reply'] ||= []
        env['rack.after_reply'] << ->() do
          self.class.call
        rescue StandardError => e
          Rails.logger.error e
          Rails.logger.error e.backtrace&.join("\n")
        end
      [status, headers, body]
    end

    def self.call
      transaction = SpanSubscriber::Base.transaction
      SpanSubscriber::Base.transaction = nil
      if transaction.nil? || transaction.name.start_with?('SolidApm::')
        SpanSubscriber::Base.spans = nil
        return
      end

      ApplicationRecord.transaction do
        transaction.save!

        SpanSubscriber::Base.spans.each do |span|
          span[:transaction_id] = transaction.id
        end
        SolidApm::Span.insert_all SpanSubscriber::Base.spans
      end
      SpanSubscriber::Base.spans = nil
    end

    def self.init_transaction
      now = Time.zone.now
      SpanSubscriber::Base.transaction = Transaction.new(
        uuid: SecureRandom.uuid,
        timestamp: now,
        unix_minute: (now.to_f / 60).to_i,
        type: 'request'
      )
      SpanSubscriber::Base.spans = []
      SpanSubscriber::Base.transaction
    end
  end
end
