require 'fast_mcp'
require_relative './middleware'

module SolidApm
  class Engine < ::Rails::Engine
    isolate_namespace SolidApm

    config.app_middleware.use Middleware

    initializer "solid_apm.assets.precompile" do |app|
      app.config.assets.precompile += %w( application.css application.js )
    end

    initializer "solid_apm.mount_mcp_server" do |app|
      FastMcp.mount_in_rails(
        app,
        name: 'solid-apm',
        version: '1.0.0',
        path_prefix: '/solid_apm/mcp',
        messages_route: 'messages',
        sse_route: 'sse',
        authenticate: true,
        auth_token: ENV.fetch('SOLID_APM_MCP_AUTH_TOKEN', nil),
      ) do |server|
        app.config.after_initialize do
          mcp_path = File.expand_path('../../../app/mcp', __FILE__)
          Dir[File.join(mcp_path, '**', '*.rb')].sort.each { |file| require file }

          server.register_resources(*SolidApm::Mcp::ApplicationResource.descendants)
          server.register_tools(*SolidApm::Mcp::ApplicationTool.descendants)
        end
      end
    end

    config.after_initialize do
      SpanSubscriber::Base.subscribe!
    end
  end
end
