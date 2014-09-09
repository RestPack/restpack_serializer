require 'spec_helper'

describe RestPack::Serializer::Attributes do
	class CustomSerializer
		include RestPack::Serializer
		attributes :a, :b, :c
		attribute :old_attribute, :key => :new_key
		attribute :number, { type: :decimal, async: true }
	end

	before do
		@attributes = CustomSerializer.serializable_attributes
		@options = CustomSerializer.serializable_attributes_options
	end

	it "correctly models specified attributes" do
		@attributes.length.should == 5
	end

	it "correctly maps normal attributes" do
		[:a, :b, :c].each do |attr|
			@attributes[attr].should == attr
		end
	end

	it "correctly maps attribute with :key options" do
		@attributes[:new_key].should == :old_attribute
	end

	it "correctly matches passed through options" do
		@options[:number][:type].should == :decimal
		@options[:number][:async].should == true
	end

	it "correctly removed key from options" do
		@options[:new_key].has_key?(:key).should == false
	end
end
