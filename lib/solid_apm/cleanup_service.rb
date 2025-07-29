# frozen_string_literal: true

module SolidApm
  class CleanupService
    # Regex to match safe time expressions like "1.week.ago", "2.months.ago", etc.
    DURATION_PATTERN = /\A(\d+)\.(second|minute|hour|day|week|month|year)s?\.ago\z/.freeze
    def initialize(older_than: '1.month.ago')
      @older_than = older_than
    end

    def call
      cutoff_time = parse_time_expression(@older_than)
      deleted_count = Transaction.where(timestamp: ...cutoff_time).destroy_all.size

      {
        cutoff_time: cutoff_time,
        deleted_count: deleted_count,
        older_than: @older_than
      }
    end

    private

    def parse_time_expression(expression)
      match = expression.match(DURATION_PATTERN)
      raise ArgumentError, 'Invalid time expression format' unless match

      number = match[1].to_i
      unit = match[2]

      case unit
      when 'second'
        number.seconds.ago
      when 'minute'
        number.minutes.ago
      when 'hour'
        number.hours.ago
      when 'day'
        number.days.ago
      when 'week'
        number.weeks.ago
      when 'month'
        number.months.ago
      when 'year'
        number.years.ago
      else
        raise ArgumentError, "Unsupported time unit: #{unit}"
      end
    end
  end
end
