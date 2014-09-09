require 'factory_girl'

FactoryGirl.define do
  factory :artist, :class => MyApp::Artist do
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

    factory :artist_with_fans do
      ignore do
        fans_count 3
      end
      after(:create) do |artist, evaluator|
        create_list(:payment, evaluator.fans_count, artist: artist)
      end
    end

    factory :artist_with_stalkers do
      ignore do
        stalker_count 2
      end
      after(:create) do |artist, evaluator|
        create_list(:stalker, evaluator.stalker_count, artists: [ artist ])
      end
    end
  end

  factory :album, :class => MyApp::Album do
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

  factory :song, :class => MyApp::Song do
    sequence(:title) {|n| "Song ##{n}" }
    artist
    album
  end

  factory :payment, :class => MyApp::Payment do
    amount 999
    artist
    fan
  end

  factory :fan, :class => MyApp::Fan do
    sequence(:name) {|n| "Fan ##{n}"}
  end

  factory :stalker, :class => MyApp::Stalker do
    sequence(:name) {|n| "Stalker ##{n}"}
  end
end
