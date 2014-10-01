# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aggrobot/version'

Gem::Specification.new do |spec|
  spec.name          = 'aggrobot'
  spec.version       = Aggrobot::VERSION
  spec.authors       = ['Shadab Ahmed']
  spec.email         = ['shadab.ansari@gmail.com']
  spec.description   = %q{Easy and performant aggregation for rails}
  spec.summary       = %q{Rails aggregation library}
  spec.homepage      = 'https://github.com/shadabahmed/aggrobot'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '>=3.1'
  spec.add_dependency 'activerecord', '>=3.1'
  spec.add_dependency 'arel'

  spec.required_ruby_version = '>= 1.8.7'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency('rspec', ['~> 2.14.1'])
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('factory_girl')
  spec.add_development_dependency('database_cleaner')
end
