require 'will_paginate'
require 'will_paginate/active_record'

require 'restpack_serializer/version'
require 'restpack_serializer/configuration'
require 'restpack_serializer/serializable'
require 'restpack_serializer/factory'
require 'restpack_serializer/result'

module RestPack
  module Serializer
    mattr_accessor :config
    @@config = Configuration.new

    def self.setup
      yield @@config
    end
  end
end
