# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/jest/version'

Gem::Specification.new do |s|
  s.name          = "guard-jest"
  s.version       = Guard::JestVersion.to_s
  s.authors       = %w[RobinDaugherty]
  s.email         = %w[robin@robindaugherty.net]

  s.description   = %q{Allows you to add jest to your Guard toolchain, so that jest is run.}
  s.summary       = %q{Guard to run jest.}
  s.homepage      = "https://github.com/RobinDaugherty/guard-jest"
  s.license       = "MIT"

  if s.respond_to?(:metadata)
    s.metadata['changelog_uri'] = 'https://github.com/RobinDaugherty/guard-jest/releases'
    s.metadata['source_code_uri'] = 'https://github.com/RobinDaugherty/guard-jest'
    s.metadata['bug_tracker_uri'] = 'https://github.com/RobinDaugherty/guard-jest/issues'
  else
    puts "Your RubyGems does not support metadata. Update if you'd like to make a release."
  end

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.0.0"

  s.add_dependency 'guard', "~> 2.1"
  s.add_dependency 'guard-compat', "~> 1.1"

  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
end
