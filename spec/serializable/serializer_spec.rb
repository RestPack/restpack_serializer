require './spec/spec_helper'

describe RestPack::Serializer do
  let(:serializer) { PersonSerializer.new }
  let(:person) { Person.new(id: 123, name: 'Gavin', age: 36) }
  class Person
    attr_accessor :id, :name, :age

    def initialize(attributes = {})
      @id = attributes[:id]
      @name = attributes[:name]
      @age = attributes[:age]
    end

    def self.table_name
      "people"
    end
  end

  context "bare bones serializer" do
    class EmptySerializer
      include RestPack::Serializer
    end

    it "serializes to an empty hash" do
      EmptySerializer.new.as_json(person).should == { }
    end
  end

  class PersonSerializer
    include RestPack::Serializer
    attributes :id, :name, :url, :admin_info

    def url
      "/api/v1/people/#{id}.json"
    end

    def admin_info
      { key: "super_secret_sauce" }
    end

    def include_admin_info?
      @options[:is_admin?]
    end
  end

  describe ".as_json" do
    it "serializes specified attributes" do
      serializer.as_json(person).should == {
        id: 123, name: 'Gavin', url: '/api/v1/people/123.json'
      }
    end

    context "with options" do
      it "excludes specified attributes" do
        serializer.as_json(person, { include_url?: false }).should == {
          id: 123, name: 'Gavin'
        }
      end

      it "excludes custom attributes if specified" do
        hash = serializer.as_json(person, { is_admin?: false })
        hash[:admin_info].should == nil
      end

      it "includes custom attributes if specified" do
        hash = serializer.as_json(person, { is_admin?: true })
        hash[:admin_info].should == { key: "super_secret_sauce" }
      end
    end

    context "links" do
      let(:serializer) { SongSerializer.new }
      it "includes 'links' data" do
        @album1 = FactoryGirl.create(:album_with_songs, song_count: 11)
        json = serializer.as_json(@album1.songs.first)
        json[:links].should == {
          artist: @album1.artist_id,
          album: @album1.id
        }
      end
    end
  end

  describe "#model_name" do
    it "extracted the Model name from the Serializer name" do
      PersonSerializer.model_name.should == "Person"
    end
  end

  describe "#model_class" do
    it "returns the correct class" do
      PersonSerializer.model_class.should == Person
    end
  end

  describe "#key" do
    it "returns the correct key" do
      PersonSerializer.key.should == :people
    end
  end
end
