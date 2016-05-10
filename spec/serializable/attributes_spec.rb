require 'spec_helper'

describe RestPack::Serializer::Attributes do
  class CustomSerializer
    include RestPack::Serializer
    attributes :a, :b, :c
    attributes :d, :e, :f?
    optional :sometimes, :maybe
    attribute :old_attribute, :key => :new_key
    transform [:gonzaga], lambda { |name, model| model.send(name).downcase }
  end

  subject(:attributes) { CustomSerializer.serializable_attributes }

  it "correctly models specified attributes" do
    expect(attributes.length).to be(10)
  end

  it "correctly maps normal attributes" do
    [:a, :b, :c, :d, :e, :f?].each do |attr|
      expect(attributes[attr]).to eq({
        name: attr,
        include_method_name: "include_#{attr}?".to_sym
      })
    end
  end

  it "correctly maps attribute with :key options" do
    expect(attributes[:new_key]).to eq({
      name: :old_attribute,
      include_method_name: :include_new_key?
    })
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

  describe "model as a hash" do
    let(:model) { { a: 'A', 'b' => 'B', c: false, :f? => 2 } }

    subject(:as_json) { CustomSerializer.as_json(model, include_gonzaga?: false) }

    it 'uses the transform method on the model attribute' do
      expect(as_json[:a]).to eq('A')
      expect(as_json[:b]).to eq('B')
      expect(as_json[:c]).to eq(false)
      expect(as_json[:f?]).to eq(2)
    end
  end
end
