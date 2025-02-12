require 'groupdate'
require 'active_median'

require "solid_apm/version"
require "solid_apm/engine"

module SolidApm
  mattr_accessor :connects_to

  def self.set_context(context)
    SpanSubscriber::Base.context = context
  end
end
