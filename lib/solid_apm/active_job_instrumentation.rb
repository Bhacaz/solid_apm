# frozen_string_literal: true

module SolidApm
  module ActiveJobInstrumentation
    def perform(*args)
      transaction = SolidApm::SpanSubscriber::Base.transaction
      if transaction
        transaction.timestamp = Time.zone.now
      end

      SolidApm::ActiveJobMiddleware.instrument_job(self, args) do
        super
      end

      if transaction
        transaction.end_time = Time.zone.now
        transaction.duration = (transaction.end_time - transaction.timestamp) * 1000
      end

      result
    end
  end
end