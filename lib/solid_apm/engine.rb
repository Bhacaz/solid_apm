require_relative './middleware'

module SolidApm
  class Engine < ::Rails::Engine
    isolate_namespace SolidApm

    config.autoload_paths << File.expand_path('../../../app/services', __FILE__)
    config.autoload_paths << File.expand_path('../../../app/mcp_tools', __FILE__)

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
