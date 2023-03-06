# frozen_string_literal: true

require 'kaminari'

require_relative 'restpack_serializer/version'
require_relative 'restpack_serializer/configuration'
require_relative 'restpack_serializer/serializable'
require_relative 'restpack_serializer/factory'
require_relative 'restpack_serializer/result'

Kaminari::Hooks.init if defined?(Kaminari::Hooks)

module RestPack
  module Serializer
    mattr_accessor :config
    @@config = Configuration.new

    def self.setup
      yield @@config
    end
  end
end
