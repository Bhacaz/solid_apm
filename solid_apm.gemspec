require_relative "lib/solid_apm/version"

Gem::Specification.new do |spec|
  spec.name        = "solid_apm"
  spec.version     = SolidApm::VERSION
  spec.authors     = ["Jean-Francis Bastien"]
  spec.email       = ["bhacaz@gmail.com"]
  spec.homepage    = "https://github.com/Bhacaz/solid_apm"
  spec.summary     = "SolidApm is a DB base engine for Application Performance Monitoring."
  spec.description = "SolidApm allow you to monitor your application without any external service."
  spec.license     = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 3.2')
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/Bhacaz/solid_apm/releases"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  end

  ">= 7.1".tap do |rails_version|
    spec.add_dependency "actionpack", rails_version
    spec.add_dependency "actionview", rails_version
    spec.add_dependency "activerecord", rails_version
    spec.add_dependency "railties", rails_version
  end
  spec.add_dependency 'apexcharts'
  spec.add_dependency 'active_median'
  spec.add_dependency "fast-mcp", "~> 1.5"
  spec.add_dependency 'groupdate'
end
