require 'active_model'
require "active_model/array_serializer"
require "active_model/serializer"
require "active_model/serializer/associations"

require './lib/restpack_serializer'

class EmptySerializer
	include RestPack::Serializable
end

class PersonSerializer
	include RestPack::Serializable
	attributes :name
end

class Person
	attr_accessor :name

  def initialize(attributes = {})
    @name = attributes[:name]
  end
end