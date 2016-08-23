# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'latest_version/version'

Gem::Specification.new do |spec|
  spec.name          = "latest_version"
  spec.version       = LatestVersion::VERSION
  spec.authors       = ["Torsten Schoenebaum"]
  spec.email         = ["torsten.schoenebaum@web.de"]

  spec.summary       = %q{Small Sinatra application that shows the latest versions of a GitHub user's repositories.}
  spec.homepage      = "https://github.com/tosch/latest_version"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://leipzig.torstenschoenebaum.de"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  spec.add_dependency "octokit"
  spec.add_dependency "haml"
  spec.add_dependency "sinatra"
  spec.add_dependency "omniauth"
  spec.add_dependency "omniauth-github"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "puma"
end
