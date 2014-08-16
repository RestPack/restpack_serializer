# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restpack_serializer/version'

Gem::Specification.new do |gem|
  gem.name          = "restpack_serializer"
  gem.version       = RestPack::Serializer::VERSION
  gem.authors       = ["Gavin Joyce"]
  gem.email         = ["gavinjoyce@gmail.com"]
  gem.description   = %q{Model serialization, paging, side-loading and filtering}
  gem.summary       = %q{Model serialization, paging, side-loading and filtering}
  gem.homepage      = "https://github.com/RestPack"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport', ['>= 4.0.3', '< 5.0']
  gem.add_dependency 'activerecord', ['>= 4.0.3', '< 5.0']
  gem.add_dependency 'kaminari', '~> 0.16.1'

  gem.add_development_dependency 'restpack_gem', '~> 0.0.9'
  gem.add_development_dependency 'rake', '~> 10.0.3'
  gem.add_development_dependency 'guard-rspec', '~> 2.5.4'
  gem.add_development_dependency 'growl', '~> 1.0.3'
  gem.add_development_dependency 'factory_girl', '~> 4.2.0'
  gem.add_development_dependency 'sqlite3', '~> 1.3.7'
  gem.add_development_dependency 'database_cleaner', '~> 1.0.1'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'bump'
  gem.add_development_dependency 'protected_attributes', '~> 1.0.5'
end
