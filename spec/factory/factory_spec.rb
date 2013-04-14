require './spec/spec_helper'

describe RestPack::Serializer::Factory do
  let(:factory) { RestPack::Serializer::Factory }

  it "creates by string" do
    factory.create("Song").should be_an_instance_of(SongSerializer)
  end
  it "creates by symbol" do
    factory.create(:song).should be_an_instance_of(SongSerializer)
  end
  it "creates by class" do
    factory.create(Song).should be_an_instance_of(SongSerializer)
  end
end