# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruth/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruth'
  spec.version       = Ruth::VERSION
  spec.authors       = ['Antun Krasic']
  spec.email         = ['antun@martuna.co']
  spec.summary       = %q(Generate Gemfile from a YAML list)
  spec.description   = %q(Gemfile generator from YAML/JSON/Hash types)
  spec.homepage      = 'https://github.com/akrasic/ruth'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.3'
end
