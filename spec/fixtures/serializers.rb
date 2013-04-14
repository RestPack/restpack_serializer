class SongSerializer
  include RestPack::Serializer
  attributes :title, :album_id
end

class AlbumSerializer
  include RestPack::Serializer
  attributes :title, :year, :artist_id
end