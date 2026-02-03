# frozen_string_literal: true

module SolidApm
  class Railtie < Rails::Railtie
    config.before_initialize do
      # Always disable in test environment to prevent test pollution
      SolidApm.enabled = false if Rails.env.test?
    end
  end
end
