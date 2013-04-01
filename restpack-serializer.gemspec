# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restpack-serializer/version'

Gem::Specification.new do |gem|
  gem.name          = "restpack-serializer"
  gem.version       = RestPack::Serializer::VERSION
  gem.authors       = ["Gavin Joyce"]
  gem.email         = ["gavinjoyce@gmail.com"]
  gem.description   = %q{Model serialization, paging, side-loading and filtering}
  gem.summary       = %q{...}
  gem.homepage      = "https://github.com/RestPack"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency 'activerecord', '>= 3.0'
  gem.add_development_dependency 'rspec', '~> 2.12'
  gem.add_development_dependency "rails", ">= 3.0"
end