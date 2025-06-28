require_relative './middleware'

module SolidApm
  class Engine < ::Rails::Engine
    isolate_namespace SolidApm

    config.app_middleware.use Middleware

    initializer "solid_apm.assets.precompile" do |app|
      app.config.assets.precompile += %w( application.css application.js )
    end

    begin
      # Mount the MCP server only if the main app added the fast_mcp in is Gemfile.
      require 'fast_mcp'
      initializer "solid_apm.mount_mcp_server" do |app|
      mcp_server_config = SolidApm.mcp_server_config.reverse_merge(
        name: 'solid-apm-mcp',
        version: '1.0.0',
        path: '/solid_apm/mcp'
      )

      FastMcp.mount_in_rails(
        app,
        **mcp_server_config
      ) do |server|
        app.config.after_initialize do
          Dir[File.join(__dir__, '../../app/resources/solid_apm/mcp/**/*.rb')].sort.each { |file| require file }
          Dir[File.join(__dir__, '../../app/tools/solid_apm/mcp/**/*.rb')].sort.each { |file| require file }
          server.register_resources(*SolidApm::Mcp::ApplicationResource.descendants)
          server.register_tools(*SolidApm::Mcp::ApplicationTool.descendants)
        end
      end
    end
    rescue LoadError
      # Ignored
    end

    config.after_initialize do
      SpanSubscriber::Base.subscribe!
    end
  end
end
