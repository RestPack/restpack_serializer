require 'spec_helper'

describe RestPack::Serializer::Attributes do
  class CustomSerializer
    include RestPack::Serializer
    attributes :a, :b, :c
    attributes :d, :e
    optional :sometimes, :maybe
    attribute :old_attribute, :key => :new_key
    transform [:gonzaga], lambda { |name, model| model.send(name).downcase }
  end

  subject(:attributes) { CustomSerializer.serializable_attributes }

  it "correctly models specified attributes" do
    expect(attributes.length).to be(9)
  end

  it "correctly maps normal attributes" do
    [:a, :b, :c, :d, :e].each do |attr|
      expect(attributes[attr]).to eq(attr)
    end
  end

  it "correctly maps attribute with :key options" do
    expect(attributes[:new_key]).to eq(:old_attribute)
  end

  describe "optional attributes" do
    let(:model) { OpenStruct.new(a: 'A', sometimes: 'SOMETIMES', gonzaga: 'GONZAGA') }
    let(:context) { {} }
    subject(:as_json) { CustomSerializer.as_json(model, context) }

    context 'with no includes context' do
      it "excludes by default" do
        expect(as_json[:sometimes]).to eq(nil)
      end
    end

    context 'with an includes context' do
      let(:context) { { include_sometimes?: true } }

      it "allows then to be included" do
        expect(as_json[:sometimes]).to eq('SOMETIMES')
      end
    end
  end

  describe '#transform_attributes' do
    let(:model) { OpenStruct.new(gonzaga: 'IS A SCHOOL') }

    subject(:as_json) { CustomSerializer.as_json(model) }

    it 'uses the transform method on the model attribute' do
      expect(as_json[:gonzaga]).to eq('is a school')
    end
  end
end
