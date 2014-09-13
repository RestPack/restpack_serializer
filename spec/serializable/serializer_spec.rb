require 'spec_helper'

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

    def to_param
      id.to_s
    end
  end

  context "bare bones serializer" do
    class EmptySerializer
      include RestPack::Serializer
    end

    it ".as_json serializes to an empty hash" do
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
      {
        "key" => "super_secret_sauce",
        "array" => [
          { "name" => "Alex" }
        ]
      }
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

  describe ".serialize" do
    it "serializes to an array" do
      serializer.class.serialize(person).should == {
        people: [{
          id: '123', name: 'Gavin', description: 'This is person #123',
          href: '/people/123', custom_key: 'custom value for model id 123'
        }]
      }
    end
  end

  describe ".as_json" do
    it "serializes specified attributes" do
      serializer.as_json(person).should == {
        id: '123', name: 'Gavin', description: 'This is person #123',
        href: '/people/123', custom_key: 'custom value for model id 123'
      }
    end

    context "an array" do
      let(:people) { [person, person] }
      it "results in a serialized array" do
        serializer.as_json(people).should == [
          {
            id: '123', name: 'Gavin', description: 'This is person #123',
            href: '/people/123', custom_key: 'custom value for model id 123'
          },
          {
            id: '123', name: 'Gavin', description: 'This is person #123',
            href: '/people/123', custom_key: 'custom value for model id 123'
          }
        ]
      end
      context "#array_as_json" do
        it "results in a serialized array" do
          serializer.class.array_as_json(people).should == [
            {
              id: '123', name: 'Gavin', description: 'This is person #123',
              href: '/people/123', custom_key: 'custom value for model id 123'
            },
            {
              id: '123', name: 'Gavin', description: 'This is person #123',
              href: '/people/123', custom_key: 'custom value for model id 123'
            }
          ]
        end
      end
    end

    context "nil" do
      it "results in nil" do
        serializer.as_json(nil).should == nil
      end
    end

    context "with options" do
      it "excludes specified attributes" do
        serializer.as_json(person, { include_description?: false }).should == {
          id: '123', name: 'Gavin', href: '/people/123',
          custom_key: 'custom value for model id 123'
        }
      end

      it "excludes custom attributes if specified" do
        hash = serializer.as_json(person, { is_admin?: false })
        hash[:admin_info].should == nil
      end

      it "includes custom attributes if specified" do
        hash = serializer.as_json(person, { is_admin?: true })
        hash[:admin_info].should == {
          key: "super_secret_sauce",
          array: [
            name: 'Alex'
          ]
        }
      end
    end

    context "links" do
      context "'belongs to' associations" do
        let(:serializer) { MyApp::SongSerializer.new }

        it "includes 'links' data for :belongs_to associations" do
          @album1 = FactoryGirl.create(:album_with_songs, song_count: 11)
          json = serializer.as_json(@album1.songs.first)
          json[:links].should == {
            artist: @album1.artist_id.to_s,
            album: @album1.id.to_s
          }
        end
      end

      context "with a serializer with has_* associations" do
        let(:artist_serializer) { MyApp::ArtistSerializer.new }
        let(:json) { artist_serializer.as_json(artist_factory) }
        let(:side_load_ids) { artist_has_association.map {|obj| obj.id.to_s } }

        describe "'has_many, through' associations" do
          let(:artist_factory) { FactoryGirl.create :artist_with_fans }
          let(:artist_has_association) { artist_factory.fans }

          it "includes 'links' data when there are associated records" do
            expect(json[:links][:fans]).to match_array(side_load_ids)
          end
        end

        describe "'has_and_belongs_to_many' associations" do
          let(:artist_factory) { FactoryGirl.create :artist_with_stalkers }
          let(:artist_has_association) { artist_factory.stalkers }

          it "includes 'links' data when there are associated records" do
            expect(json[:links][:stalkers]).to match_array(side_load_ids)
          end
        end
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
    context "with default key" do
      it "returns the correct key" do
        PersonSerializer.key.should == :people
      end

      it "has correct #singular_key" do
        PersonSerializer.singular_key.should == :person
      end

      it "has correct #plural_key" do
        PersonSerializer.plural_key.should == :people
      end
    end

    context "with custom key" do
      class SerializerWithCustomKey
        include RestPack::Serializer
        self.key = :customers
      end

      it "returns the correct key" do
        SerializerWithCustomKey.key.should == :customers
      end

      it "has correct #singular_key" do
        SerializerWithCustomKey.singular_key.should == :customer
      end
    end
  end
end
