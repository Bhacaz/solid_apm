# frozen_string_literal: true

module SpanSubscriber
  class ActionViewRender < Base
    PATTERN = /^render_.+\.action_view/

    def summary(payload)
      identifier = payload[:identifier]
      sanitize_path(identifier)
    end

    private

    def sanitize_path(path)
      if path.start_with? Rails.root.to_s
        app_path(path)
      else
        gem_path(path)
      end
    end

    def app_path(path)
      return unless path.start_with? Rails.root.to_s

      format '$APP_PATH%s', path[Rails.root.to_s.length, path.length]
    end

    def gem_path(path)
      root = Gem.path.find { |gp| path.start_with? gp }
      return unless root

      format '$GEM_PATH%s', path[root.length, path.length]
    end
  end
end
