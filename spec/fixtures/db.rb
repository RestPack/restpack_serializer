require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'test.db'
)

load "spec/fixtures/schema.rb"

class Artist < ActiveRecord::Base
  attr_accessible :name, :website
end

class Album < ActiveRecord::Base
  attr_accessible :title, :year, :artist

  belongs_to :artist
end

class Song < ActiveRecord::Base
  attr_accessible :title, :artist, :album

  belongs_to :artist
  belongs_to :album
end

radiohead       = Artist.create(name: 'Radiohead', website: 'www.radiohead.com')
john_frusciante = Artist.create(name: 'John Frusciante', website: 'johnfrusciante.com')
nick_cave       = Artist.create(name: 'Nick Cave', website: 'www.nickcave.com')

Album.create title: 'Pablo Honey', year: 1993, artist: radiohead
Album.create title: 'The Bends', year: 1995, artist: radiohead
Album.create title: 'OK Computer', year: 1997, artist: radiohead
Album.create title: 'Kid A', year: 2000, artist: radiohead
Album.create title: 'Amnesiac', year: 2001, artist: radiohead
Album.create title: 'Hail to the Thief', year: 2003, artist: radiohead
in_rainbows = Album.create title: 'In Rainbows', year: 2007, artist: radiohead
tkol = Album.create title: 'The King of Limbs', year: 2011, artist: radiohead

['Bloom', 'Morning Mr Magpie', 'Little by Little', 'Feral', 'Lotus Flower',
'Codex', 'Give Up the Ghost', 'Seperator'].each do |title|
  Song.create title: title, album: tkol, artist: radiohead
end

['15 Step', 'Bodysnatchers', 'Nude', 'Weird Fishes/Arpeggi', 'All I Need', 
  'Faust Arp', 'Reckoner', 'House of Cards', 'Jigsaw Falling into Place', 
  'Videotape'].each do |title|
  Song.create title: title, album: in_rainbows, artist: radiohead
end