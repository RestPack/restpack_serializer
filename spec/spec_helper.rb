require 'rspec'
require './lib/restpack_serializer'
require 'logger'
require './spec/fixtures/db'
require './spec/fixtures/serializers'
require './spec/support/factory'
require 'database_cleaner'
require 'coveralls'

Coveralls::Output.silent = true unless ENV["CI"]
Coveralls.wear!
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.raise_errors_for_deprecations!

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
