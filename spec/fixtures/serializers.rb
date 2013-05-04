class SongSerializer
  include RestPack::Serializer
  attributes :id, :title, :album_id
  can_filter_by :id, :title, :album_id
end

class AlbumSerializer
  include RestPack::Serializer
  attributes :id, :title, :year, :artist_id
  can_filter_by :id, :artist_id
end

class ArtistSerializer
  include RestPack::Serializer
  attributes :id, :name, :website
  can_filter_by :id
end