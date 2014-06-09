require 'spec_helper'

describe RestPack::Serializer::Sortable do
  class CustomSerializer
    include RestPack::Serializer
    attributes :a, :b, :c

    can_sort_by :a, :c
  end

  it 'captures the specified sorting attributes' do
    CustomSerializer.serializable_sorting_attributes.should == [:a, :c]
  end
end
