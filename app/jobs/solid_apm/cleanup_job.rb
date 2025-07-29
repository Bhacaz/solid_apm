# frozen_string_literal: true

module SolidApm
  class CleanupJob < ApplicationJob
    def perform(older_than = '1.month.ago')
      result = CleanupService.new(older_than: older_than).call

      Rails.logger.info "SolidApm::CleanupJob completed: deleted #{result[:deleted_count]} transactions older than #{result[:cutoff_time]} (#{result[:older_than]})"

      result
    end
  end
end
