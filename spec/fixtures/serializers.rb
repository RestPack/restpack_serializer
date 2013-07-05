class SongSerializer
  include RestPack::Serializer
  attributes :id, :title, :album_id
  can_include :albums, :artists
end

class AlbumSerializer
  include RestPack::Serializer
  attributes :id, :title, :year, :artist_id
  can_include :artists, :songs
end

class ArtistSerializer
  include RestPack::Serializer
  attributes :id, :name, :website
  can_include :albums, :songs
end
