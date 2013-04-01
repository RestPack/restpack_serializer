require './spec/spec_helper'

describe RestPack::Serializable::Attributes do
	class CustomSerializer
		include RestPack::Serializable
		attributes :a, :b, :c
		attribute :old_attribute, :key => :new_key
	end

	before do
		@attributes = CustomSerializer.serializable_attributes
	end

	it "has four attributes" do
		@attributes.length.should == 4
	end

	it "has three simple attributes" do
		[:a, :b, :c].each do |attr|
			@attributes[attr].should == attr
		end
	end

	it "has key mapped attribute" do
		@attributes[:new_key].should == :old_attribute
	end
end