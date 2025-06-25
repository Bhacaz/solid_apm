require_relative './middleware'

module SolidApm
  class Engine < ::Rails::Engine
    isolate_namespace SolidApm

    config.app_middleware.use Middleware

    initializer "solid_apm.assets.precompile" do |app|
      app.config.assets.precompile += %w( application.css application.js )
    end

    config.after_initialize do
      SpanSubscriber::Base.subscribe!
      # require_relative '../../config/fast_mcp'
    end
  end
end
