require './spec/spec_helper'

describe RestPack::Serializer::Attributes do
	class CustomSerializer
		include RestPack::Serializer
		attributes :a, :b, :c
		attribute :old_attribute, :key => :new_key
	end

	before do
		@attributes = CustomSerializer.serializable_attributes
	end

	it "correctly models specified attributes" do
		@attributes.length.should == 4
	end

	it "correctly maps normal attributes" do
		[:a, :b, :c].each do |attr|
			@attributes[attr].should == attr
		end
	end

	it "correctly maps attribute with :key options" do
		@attributes[:new_key].should == :old_attribute
	end
end