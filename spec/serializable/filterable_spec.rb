require 'spec_helper'

describe RestPack::Serializer::Filterable do
  class CustomSerializer
    include RestPack::Serializer
    attributes :a, :b, :c

    can_filter_by :a, :c
  end

  it "captures the specified filters" do
    CustomSerializer.serializable_filters.should == [:a, :c]
  end
end
