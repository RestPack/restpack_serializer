require 'spec_helper'

describe RestPack::Serializer::Sortable do
  class CustomSerializer
    include RestPack::Serializer
    attributes :a, :b, :c

    can_sort_by :a, :c
  end

  it 'captures the specified sorting attributes' do
    expect(CustomSerializer.serializable_sorting_attributes).to eq([:a, :c])
  end
end
