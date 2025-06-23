# frozen_string_literal: true

module SolidApm
  module SpanSubscriber
    class ActionViewRender < Base
      PATTERN = /^render_.+\.action_view/

      def summary(payload)
        identifier = payload[:identifier]
        clean_trace(identifier)
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

         path[Rails.root.to_s.length + 1, path.length]
      end

      def gem_path(path)
        root = Gem.path.find { |gp| path.start_with? gp }
        return unless root

        path[root.length + 1, path.length]
      end
    end
  end
end
