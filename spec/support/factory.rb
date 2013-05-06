  require 'factory_girl'

FactoryGirl.define do
  factory :artist do
    sequence(:name) {|n| "Artist ##{n}" }
    sequence(:website) {|n| "http://website#{n}.com/" }

    factory :artist_with_albums do
      ignore do
        album_count 3
      end

      after(:create) do |artist, evaluator|
        create_list(:album_with_songs, evaluator.album_count, artist: artist)
      end
    end
  end

  factory :album do
    sequence(:title) {|n| "Album ##{n}" }
    sequence(:year) {|n| 1960 + n }
    artist

    factory :album_with_songs do
      ignore do
        song_count 10
      end

      after(:create) do |album, evaluator|
        create_list(:song, evaluator.song_count, album: album, artist: album.artist)
      end
    end
  end

  factory :song do
    sequence(:title) {|n| "Song ##{n}" }
    artist
    album
  end

  factory :payment do
    amount 999
    artist
  end
end