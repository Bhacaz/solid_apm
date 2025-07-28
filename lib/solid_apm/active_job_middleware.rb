# frozen_string_literal: true

module SolidApm
  class ActiveJobMiddleware
    def call(job)
      self.class.init_transaction(job)
      yield
    rescue StandardError => e
      Rails.logger.error e
      Rails.logger.error e.backtrace&.join("\n")
      raise e
    ensure
      self.class.call
    end

    # Class method to instrument job execution (for automatic instrumentation)
    def self.instrument_job(job_class, args)
      job_instance = job_class.new(*args)
      init_transaction(job_instance)
      
      begin
        result = yield
        call
        result
      rescue StandardError => e
        call
        raise e
      end
    end

    def self.call
      transaction = SpanSubscriber::Base.transaction
      SpanSubscriber::Base.transaction = nil

      if transaction.nil? ||
          Middleware.transaction_filtered?(transaction.name) ||
          !Sampler.should_sample?

        SpanSubscriber::Base.spans = nil
        return
      end

      Middleware.with_silence_logger do
        ApplicationRecord.transaction do
          transaction.save!

          SpanSubscriber::Base.spans.each do |span|
            span[:transaction_id] = transaction.id
          end
          SolidApm::Span.insert_all SpanSubscriber::Base.spans if SpanSubscriber::Base.spans.any?
        end
      end
      SpanSubscriber::Base.spans = nil
    end

    # Initialize a new job transaction and reset spans
    def self.init_transaction(job)
      now = Time.zone.now
      SpanSubscriber::Base.transaction = Transaction.new(
        uuid: SecureRandom.uuid,
        unix_minute: (now.to_f / 60).to_i,
        type: 'job',
        name: job.class.name,
        timestamp: now
      )
      SpanSubscriber::Base.spans = []
      SpanSubscriber::Base.transaction
    end
  end
end