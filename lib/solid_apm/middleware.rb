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

      if transaction.nil? ||
          transaction_filtered?(transaction.name) ||
          !Sampler.should_sample?

        SpanSubscriber::Base.spans = nil
        return
      end

      with_silence_logger do
        ApplicationRecord.transaction do
          transaction.save!

          SpanSubscriber::Base.spans.each do |span|
            span[:transaction_id] = transaction.id
          end
          SolidApm::Span.insert_all SpanSubscriber::Base.spans
        end
      end
      SpanSubscriber::Base.spans = nil
    end

    def self.transaction_filtered?(transaction_name)
      SolidApm.transaction_filters.any? do |filter|
        case filter
        when String
          transaction_name == filter
        when Regexp
          filter.match?(transaction_name)
        else
          false
        end
      end
    end

    def self.with_silence_logger
      if SolidApm.silence_active_record_logger && ActiveRecord::Base.logger
        ActiveRecord::Base.logger.silence { yield }
      else
        yield
      end
    end

    # Initialize a new transaction and reset spans

    def self.init_transaction
      now = Time.zone.now
      SpanSubscriber::Base.transaction = Transaction.new(
        uuid: SecureRandom.uuid,
        unix_minute: (now.to_f / 60).to_i,
        type: 'request'
      )
      SpanSubscriber::Base.spans = []
      SpanSubscriber::Base.transaction
    end
  end
end
