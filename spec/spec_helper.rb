require 'active_model'
require "active_model/array_serializer"
require "active_model/serializer"
require "active_model/serializer/associations"

require './lib/restpack_serializer'
require './spec/fixtures/db'

class SongSerializer
  include RestPack::Serializer
  attributes :title, :album_id
end

class AlbumSerializer
  include RestPack::Serializer
  attributes :title, :year, :artist_id
end