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
      EmptySerializer.as_json(person).should == { }
    end
  end

  class PersonSerializer
    include RestPack::Serializer
    attributes :id, :name, :description, :href, :admin_info

    def description
      "This is person ##{id}"
    end

    def admin_info
      { key: "super_secret_sauce" }
    end

    def include_admin_info?
      @context[:is_admin?]
    end

    def custom_attributes
      {
        :custom_key => "custom value for model id #{@model.id}"
      }
    end
  end

  describe ".as_json" do
    it "serializes specified attributes" do
      serializer.as_json(person).should == {
        id: '123', name: 'Gavin', description: 'This is person #123',
        href: '/people/123.json', custom_key: 'custom value for model id 123'
      }
    end

    context "with options" do
      it "excludes specified attributes" do
        serializer.as_json(person, { include_description?: false }).should == {
          id: '123', name: 'Gavin', href: '/people/123.json',
          custom_key: 'custom value for model id 123'
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
          artist: @album1.artist_id.to_s,
          album: @album1.id.to_s
        }
      end
    end
  end

  describe "#model_class" do
    it "extracts the Model name from the Serializer name" do
      PersonSerializer.model_class.should == Person
    end

    context "with namespaced model class" do
      module SomeNamespace
        class Model
        end
      end

      class NamespacedSerializer
        include RestPack::Serializer
        self.model_class = SomeNamespace::Model
      end

      it "returns the correct class" do
        NamespacedSerializer.model_class.should == SomeNamespace::Model
      end
    end
  end

  describe "#key" do
    it "returns the correct key" do
      PersonSerializer.key.should == :people
    end

    context "with custom key" do
      class SerializerWithCustomKey
        include RestPack::Serializer
        self.key = :custom_key
      end

      it "returns the correct key" do
        SerializerWithCustomKey.key.should == :custom_key
      end
    end
  end
end
