# frozen_string_literal: true

module SolidApm
  class TracesMcpResource < ApplicationMcpResource
    uri "solid-apm://traces/{id}"
    resource_name "traces"
    mime_type "application/json"

    def content
      JSON.generate(Trace.find(params[:id]).as_json)
    end
  end
end
