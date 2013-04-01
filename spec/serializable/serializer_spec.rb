require './spec/spec_helper'

describe RestPack::Serializable do

  class Person
    attr_accessor :id, :name, :age

    def initialize(attributes = {})
      @id = attributes[:id]
      @name = attributes[:name]
      @age = attributes[:age]
    end
  end

  class PersonSerializer
    include RestPack::Serializable
    attributes :id, :name, :url, :admin_info

    def url
      "/api/v1/people/#{id}.json"
    end

    def options
      @options
    end

    def admin_info
      { key: "super_secret_sauce" }
    end

    def include_admin_info?
      @options[:is_admin?]
    end
  end

  describe "#as_json" do
    let(:person) { Person.new(id: 123, name: 'Gavin', age: 36) }
    let(:serializer) { PersonSerializer.new }

    it "serializes specified attributes" do
      hash = serializer.as_json(person)
      hash.should == { id: 123, name: 'Gavin', url: '/api/v1/people/123.json' }
    end

    context "with options" do
      it "excludes specified attributes" do
        hash = serializer.as_json(person, { include_url?: false })
        hash.should == { id: 123, name: 'Gavin' }
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
  end
end