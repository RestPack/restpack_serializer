require './spec/spec_helper'

describe RestPack::Serializer::Factory do
  let(:factory) { RestPack::Serializer::Factory }

  it "creates a serializer by string" do
    factory.create("Song").should be_an_instance_of(SongSerializer)
  end
  it "creates a serializer by symbol" do
    factory.create(:song).should be_an_instance_of(SongSerializer)
  end
  it "creates a serializer by class" do
    factory.create(Song).should be_an_instance_of(SongSerializer)
  end
end