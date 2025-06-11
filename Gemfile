source 'https://rubygems.org'

gemspec

gem 'coveralls', require: false
gem 'memory_profiler', require: false

if RUBY_VERSION < "2.2"
  gem "sqlite3", "~> 1.3.0"
elsif RUBY_VERSION < "2.5"
  gem "sqlite3", "~> 1.4.0"
  gem "term-ansicolor", "< 1.10.3"
end
