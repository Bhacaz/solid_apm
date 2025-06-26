# frozen_string_literal: true

require 'fast_mcp'

class CreateUserTool < FastMcp::Tool
  description "Create a user"
  # These arguments will generate the needed JSON to be presented to the MCP Client
  # And they will be validated at run time.
  # The validation is based off Dry-Schema, with the addition of the description.
  arguments do
    required(:first_name).filled(:string).description("First name of the user")
    optional(:age).filled(:integer).description("Age of the user")
    required(:address).hash do
      optional(:street).filled(:string)
      optional(:city).filled(:string)
      optional(:zipcode).filled(:string)
    end
  end

  def call(first_name:, age: nil, address: {})
    User.create!(first_name:, age:, address:)
  end
end

# Register the tool with the server


FastMcp.mount_in_rails(
  Rails.application,
  name: 'solid-apm',
  version: '1.0.0',
  path_prefix: '/mcp', # This is the default path prefix
  messages_route: 'messages', # This is the default route for the messages endpoint
  sse_route: 'sse', # This is the default route for the SSE endpoint
  logger: Logger.new(STDOUT),
# Add allowed origins below, it defaults to Rails.application.config.hosts
# allowed_origins: ['localhost', '127.0.0.1', 'example.com', /.*\.example\.com/],
# localhost_only: true, # Set to false to allow connections from other hosts
# whitelist specific ips to if you want to run on localhost and allow connections from other IPs
# allowed_ips: ['127.0.0.1', '::1']
# authenticate: true,       # Uncomment to enable authentication
# auth_token: 'your-token' # Required if authenticate: true
  # auth_header_name: 'X-API-Key',  # Default is 'Authorization'
  ) do |server|
  Rails.application.config.after_initialize do
    require_relative '../../../../app/mcp_resources/application_mcp_resource'
    require_relative '../../../../app/mcp_resources/spans_mcp_tool'
    require_relative '../../../../app/mcp_resources/longest_transaction_resource'
    require_relative '../../../../app/mcp_resources/impactful_transactions_resource'
    # FastMcp will automatically discover and register:
    # - All classes that inherit from ApplicationTool (which uses ActionTool::Base)
    # - All classes that inherit from ApplicationResource (which uses ActionResource::Base)
    # server.register_tools(*ApplicationTool.descendants)
    # server.register_resources(*ApplicationResource.descendants)
    server.register_resources(*SolidApm::ApplicationMcpResource.descendants)
    server.register_tool(SolidApm::SpansMcpTool)
    # alternatively, you can register tools and resources manually:
    # server.register_tool(MyTool)
    # server.register_resource(MyResource)
  end
end
