# frozen_string_literal: true

module SpanSubscriber
  class Base
    cattr_accessor :subscribers, default: Set.new
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

        parent_id = Base.spans.last&.dig(:id)
        subtype, type = name.split('.')
        span = {
          uuid: SecureRandom.uuid,
          parent_id: parent_id,
          sequence: Base.spans.size + 1,
          timestamp: start,
          end_time: finish,
          duration: ((finish.to_f - start.to_f) * 1000).round(2),
          name: name,
          type: type,
          subtype: subtype,
          summary: self.new.summary(payload),
        }

        SpanSubscriber::Base.spans << span
      end
    end

    # private_class_method :subscribe
  end
end
