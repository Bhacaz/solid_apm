# frozen_string_literal: true
module SolidApm
  module SpanSubscriber
    class Base
      # PATTERN = /.*/

      class_attribute :subscribers, default: Set.new
      thread_cattr_accessor :transaction
      thread_cattr_accessor :spans

      def self.inherited(subclass)
        subscribers << subclass
      end

      def self.subscribe!
        subscribers.each(&:subscribe)
      end

      def self.subscribe
        ActiveSupport::Notifications.subscribe(self::PATTERN) do |name, start, finish, id, payload|
          next unless SpanSubscriber::Base.transaction

          subtype, type = name.split('.')
          duration = ((finish.to_f - start.to_f) * 1000).round(6)

          span = {
            uuid: SecureRandom.uuid,
            sequence: SpanSubscriber::Base.spans.size + 1,
            timestamp: start,
            end_time: finish,
            duration: duration,
            name: name,
            type: type,
            subtype: subtype,
            summary: self.new.summary(payload),
          }

          SpanSubscriber::Base.spans << span

          # Allow the subscriber to yield additional spans, like ending the transaction
          yield(name, start, finish, id, payload) if block_given?
        end
      end

      # def summary(payload)
      #   if payload.is_a?(Hash)
      #     payload.first.last.inspect
      #   else
      #     payload.inspect
      #   end
      # end

      # private_class_method :subscribe
    end
  end
end

Dir[File.join(__dir__, '*.rb')].sort.each { |file| require file }
