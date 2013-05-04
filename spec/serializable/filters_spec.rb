require './spec/spec_helper'

describe RestPack::Serializer::Filters do
  context "when defining :can_filter_by" do
    class CustomSerializer
      include RestPack::Serializer
      can_filter_by :a, :b, :c, :c
    end

    it "has maintains an array of filters" do
      CustomSerializer.filterable_by.should == [:a, :b, :c]
    end
  end
end