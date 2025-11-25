require_relative './middleware'

module SolidApm
  class Engine < ::Rails::Engine
    isolate_namespace SolidApm

    config.app_middleware.use Middleware

    initializer 'solid_apm.assets' do |app|
      # Add engine's assets to the load path for both Propshaft and Sprockets
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join('app/assets/stylesheets')
        app.config.assets.paths << root.join('app/assets/javascripts')

        # For Sprockets
        unless defined?(Propshaft)
          app.config.assets.precompile += %w[
            solid_apm/application.css
            solid_apm/application.js
          ]
        end
      end
    end

    begin
      # Mount the MCP server only if the main app added the fast_mcp in is Gemfile.
      require 'fast_mcp'
      initializer 'solid_apm.mount_mcp_server' do |app|
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
            require_relative 'mcp/spans_for_transaction_tool'
            require_relative 'mcp/impactful_transactions_resource'
            server.register_resources(SolidApm::Mcp::ImpactfulTransactionsResource)
            server.register_tools(SolidApm::Mcp::SpansForTransactionTool)
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
