require 'spec_helper'

describe RestPack::Serializer::Attributes do
  class CustomSerializer
    include RestPack::Serializer
    attributes :a, :b, :c
    attribute :old_attribute, :key => :new_key
    transform [:gonzaga], lambda { |name, model| model.send(name).downcase }
  end

  subject(:attributes) { CustomSerializer.serializable_attributes }

  it "correctly models specified attributes" do
    expect(attributes.length).to be(5)
  end

  it "correctly maps normal attributes" do
    [:a, :b, :c].each do |attr|
      expect(attributes[attr]).to eq(attr)
    end
  end

  it "correctly maps attribute with :key options" do
    expect(attributes[:new_key]).to eq(:old_attribute)
  end

  describe '#transform_attributes' do
    let(:model) { OpenStruct.new(gonzaga: 'IS A SCHOOL') }

    subject(:as_serialized) { CustomSerializer.as_serialized(model) }

    it 'uses the transform method on the model attribute' do
      expect(as_serialized[:gonzaga]).to eq('is a school')
    end
  end
end
