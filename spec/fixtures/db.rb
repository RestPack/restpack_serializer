require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'test.db'
)

ActiveRecord::Schema.define(:version => 1) do
  create_table "artists", :force => true do |t|
    t.string   "name"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "albums", :force => true do |t|
    t.string   "title"
    t.integer  "year"
    t.integer  "artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "songs", :force => true do |t|
    t.string   "title"
    t.integer  "album_id"
    t.integer  "artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end

class Artist < ActiveRecord::Base
  attr_accessible :name, :website

  has_many :albums
  has_many :songs
end

class Album < ActiveRecord::Base
  attr_accessible :title, :year, :artist

  belongs_to :artist
  has_many :songs
end

class Song < ActiveRecord::Base
  attr_accessible :title, :artist, :album

  belongs_to :artist
  belongs_to :album
end