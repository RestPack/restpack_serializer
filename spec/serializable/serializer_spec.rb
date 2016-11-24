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
      expect(EmptySerializer.as_json(person)).to eq({})
    end
  end

  context "serializer inheritance" do
    class BaseSerializer
      include RestPack::Serializer
      attributes :name, :colour
      optional :count

      def name
        @context[:name]
      end

      def count
        99
      end

      def age
        -2
      end

      def colour
        'purple'
      end

      def include_colour?
        false
      end
    end

    class DerivedSerializer < BaseSerializer
      attributes :name, :age, :food, :colour, :count

      def age
        @context[:age]
      end

      def food
        'crackers'
      end
    end

    it ".as_json serializes" do
      serialized = DerivedSerializer.as_json({}, include_food?: false, name: 'Ben', age: 1)
      expect(serialized).to eq({ #NOTE: I think this should include colour as DerivedSerializer defines it, but this would be a big breaking change
        name: "Ben",
        age: 1
      })
    end
  end

  class PersonSerializer
    include RestPack::Serializer
    attributes :id, :name, :description, :href, :admin_info, :string_keys

    def description
      "This is person ##{id}"
    end

    def admin_info
      {
        key: "super_secret_sauce",
        array: [
          { name: "Alex" }
        ]
      }
    end

    def include_admin_info?
      @context[:is_admin?]
    end

    def string_keys
      {
        "kid_b" => "Ben",
        "likes" => {
          "foods" => ["crackers", "stawberries"],
          "books" => ["Dumpy", "That's Not My Tiger"]
        }
      }
    end

    def include_string_keys?
      @context[:is_ben?]
    end

    def custom_attributes
      {
        custom_key: "custom value for model id #{@model.id}"
      }
    end
  end

  describe ".serialize" do
    it "serializes to an array" do
      expect(serializer.class.serialize(person)).to eq(
        people: [{
          id: '123', name: 'Gavin', description: 'This is person #123',
          href: '/people/123', custom_key: 'custom value for model id 123'
        }]
      )
    end
  end

  describe ".as_json" do
    it "serializes specified attributes" do
      expect(serializer.as_json(person)).to eq(
        id: '123', name: 'Gavin', description: 'This is person #123',
        href: '/people/123', custom_key: 'custom value for model id 123'
      )
    end

    context "an array" do
      let(:people) { [person, person] }

      it "results in a serialized array" do
        expect(serializer.as_json(people)).to eq([
          {
            id: '123', name: 'Gavin', description: 'This is person #123',
            href: '/people/123', custom_key: 'custom value for model id 123'
          },
          {
            id: '123', name: 'Gavin', description: 'This is person #123',
            href: '/people/123', custom_key: 'custom value for model id 123'
          }
        ])
      end

      context "#array_as_json" do
        it "results in a serialized array" do
          expect(serializer.class.array_as_json(people)).to eq([
            {
              id: '123', name: 'Gavin', description: 'This is person #123',
              href: '/people/123', custom_key: 'custom value for model id 123'
            },
            {
              id: '123', name: 'Gavin', description: 'This is person #123',
              href: '/people/123', custom_key: 'custom value for model id 123'
            }
          ])
        end
      end
    end

    context "nil" do
      it "results in nil" do
        expect(serializer.as_json(nil)).to eq(nil)
      end
    end

    context "with options" do
      it "excludes specified attributes" do
        expect(serializer.as_json(person, include_description?: false)).to eq(
          id: '123', name: 'Gavin', href: '/people/123',
          custom_key: 'custom value for model id 123'
        )
      end

      it "excludes custom attributes if specified" do
        hash = serializer.as_json(person, is_admin?: false)
        expect(hash[:admin_info]).to eq(nil)
      end

      it "includes custom attributes if specified" do
        hash = serializer.as_json(person, is_admin?: true)
        expect(hash[:admin_info]).to eq(
          key: "super_secret_sauce",
          array: [
            name: 'Alex'
          ]
        )
      end

      it "excludes a blacklist of attributes if specified as an array" do
        expect(serializer.as_json(person, attribute_blacklist: [:name, :description])).to eq(
          id: '123',
          href: '/people/123',
          custom_key: 'custom value for model id 123'
        )
      end

      it "excludes a blacklist of attributes if specified as a string" do
        expect(serializer.as_json(person, attribute_blacklist: 'name, description')).to eq(
          id: '123',
          href: '/people/123',
          custom_key: 'custom value for model id 123'
        )
      end

      it "includes a whitelist of attributes if specified as an array" do
        expect(serializer.as_json(person, attribute_whitelist: [:name, :description])).to eq(
          name: 'Gavin',
          description: 'This is person #123',
          custom_key: 'custom value for model id 123'
        )
      end

      it "includes a whitelist of attributes if specified as a string" do
        expect(serializer.as_json(person, attribute_whitelist: 'name, description')).to eq(
          name: 'Gavin',
          description: 'This is person #123',
          custom_key: 'custom value for model id 123'
        )
      end

      it "raises an exception if both the whitelist and blacklist are provided" do
        expect do
          serializer.as_json(person, attribute_whitelist: [:name], attribute_blacklist: [:id])
        end.to raise_error(ArgumentError, "the context can't define both an `attribute_whitelist` and an `attribute_blacklist`")
      end
    end

    context "links" do
      context "'belongs to' associations" do
        let(:serializer) { MyApp::SongSerializer.new }

        it "includes 'links' data for :belongs_to associations" do
          @album1 = FactoryGirl.create(:album_with_songs, song_count: 11)
          json = serializer.as_json(@album1.songs.first)
          expect(json[:links]).to eq(
            artist: @album1.artist_id.to_s,
            album: @album1.id.to_s
          )
        end
      end

      context "with a serializer with has_* associations" do
        let(:artist_factory) { FactoryGirl.create :artist_with_fans }
        let(:artist_serializer) { MyApp::ArtistSerializer.new }
        let(:json) { artist_serializer.as_json(artist_factory) }
        let(:side_load_ids) { artist_has_association.map { |obj| obj.id.to_s } }

        context "when the association has been eager loaded" do
          before do
            allow(artist_factory.fans).to receive(:loaded?).and_return(true)
          end

          it "does not make a query to retrieve id values" do
            expect(artist_factory.fans).not_to receive(:pluck)
            json
          end
        end


        describe "'has_many, through' associations" do
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
      expect(PersonSerializer.model_class).to eq(Person)
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
        expect(NamespacedSerializer.model_class).to eq(SomeNamespace::Model)
      end
    end
  end

  describe "#key" do
    context "with default key" do
      it "returns the correct key" do
        expect(PersonSerializer.key).to eq(:people)
      end

      it "has correct #singular_key" do
        expect(PersonSerializer.singular_key).to eq(:person)
      end

      it "has correct #plural_key" do
        expect(PersonSerializer.plural_key).to eq(:people)
      end
    end

    context "with custom key" do
      class SerializerWithCustomKey
        include RestPack::Serializer
        self.key = :customers
      end

      it "returns the correct key" do
        expect(SerializerWithCustomKey.key).to eq(:customers)
      end

      it "has correct #singular_key" do
        expect(SerializerWithCustomKey.singular_key).to eq(:customer)
      end
    end
  end
end
