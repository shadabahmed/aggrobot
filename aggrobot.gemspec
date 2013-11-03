# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aggrobot/version'

Gem::Specification.new do |spec|
  spec.name          = "aggrobot"
  spec.version       = Aggrobot::VERSION
  spec.authors       = ["Shadab Ahmed"]
  spec.email         = ["shadab.ansari@gmail.com"]
  spec.description   = %q{Easy and performant aggregation for rails}
  spec.summary       = %q{Rails aggregation library}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
