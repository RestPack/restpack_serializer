require 'spec_helper'

describe RestPack::Serializer::Parameterizable do
  class CustomSerializer
    include RestPack::Serializer
    attributes :a, :b, :c

    allow_parameters :a, :z
  end

  it 'captures the specified parameters' do
    CustomSerializer.serializable_parameters.should == [:a, :z]
  end
end
