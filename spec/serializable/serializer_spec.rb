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
    attributes :id, :name, :url

    def url
      "/api/v1/people/#{id}.json"
    end
  end

  describe "#as_json" do
    it "serializes specified attributes" do
      person = Person.new(id: 123, name: 'Gavin', age: 36)
      hash = PersonSerializer.new.as_json(person)

      hash.should == { id: 123, name: 'Gavin', url: '/api/v1/people/123.json' }
    end
  end
end