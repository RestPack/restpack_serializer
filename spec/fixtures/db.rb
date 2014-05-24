require 'sqlite3'
require 'active_record'
require 'protected_attributes'

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

  create_table "payments", :force => true do |t|
    t.integer "amount"
    t.integer  "artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items", :force => true do |t|
    t.integer  "album_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end

module MyApp
  class Artist < ActiveRecord::Base
    attr_accessible :name, :website

    has_many :albums
    has_many :songs
    has_many :payments
  end

  class Album < ActiveRecord::Base
    attr_accessible :title, :year, :artist
    scope :classic, -> { where("year < 1950") }

    belongs_to :artist
    has_many :songs
  end

  class Song < ActiveRecord::Base
    attr_accessible :title, :artist, :album

    belongs_to :artist
    belongs_to :album
  end

  class Payment < ActiveRecord::Base
    attr_accessible :amount, :artist

    belongs_to :artist
  end

  class OrderItem < ActiveRecord::Base
    attr_accessible :id, :album

    belongs_to :album
  end
end
