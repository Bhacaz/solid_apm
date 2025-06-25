# # frozen_string_literal: true
#
# require 'fast_mcp'
#
# p SolidApm::Engine.application.class.module_parent_name.underscore.dasherize
#
# FastMcp.mount_in_rails(
#   SolidApm::Engine.engine_name,
#   name: SolidApm::Engine.application.class.module_parent_name.underscore.dasherize,
#   version: '1.0.0',
#   path_prefix: '/mcp', # This is the default path prefix
#   messages_route: 'messages', # This is the default route for the messages endpoint
#   sse_route: 'sse', # This is the default route for the SSE endpoint
# # Add allowed origins below, it defaults to Rails.application.config.hosts
# # allowed_origins: ['localhost', '127.0.0.1', 'example.com', /.*\.example\.com/],
# # localhost_only: true, # Set to false to allow connections from other hosts
# # whitelist specific ips to if you want to run on localhost and allow connections from other IPs
# # allowed_ips: ['127.0.0.1', '::1']
# # authenticate: true,       # Uncomment to enable authentication
# # auth_token: 'your-token' # Required if authenticate: true
#   ) do |server|
#   SolidApm::Engine.application.config.after_initialize do
#     # FastMcp will automatically discover and register:
#     # - All classes that inherit from ApplicationTool (which uses ActionTool::Base)
#     # - All classes that inherit from ApplicationResource (which uses ActionResource::Base)
#     # server.register_tools(*ApplicationTool.descendants)
#     server.register_resources(*ApplicationResource.descendants)
#     # alternatively, you can register tools and resources manually:
#     # server.register_tool(MyTool)
#     # server.register_resource(MyResource)
#   end
# end
