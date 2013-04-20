require './lib/restpack_serializer'
require './spec/fixtures/db'
require './spec/fixtures/serializers'
require './spec/support/factory'

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end