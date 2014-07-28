require 'kaminari'

require 'restpack_serializer/version'
require 'restpack_serializer/configuration'
require 'restpack_serializer/serializable'
require 'restpack_serializer/factory'
require 'restpack_serializer/result'

Kaminari::Hooks.init

module RestPack
  module Serializer
    mattr_accessor :config
    @@config = Configuration.new

    def self.setup
      yield @@config
    end
  end
end
