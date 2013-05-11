require './spec/spec_helper'

describe RestPack::Serializer::Factory do
  let(:factory) { RestPack::Serializer::Factory }

  it "creates by string" do
    factory.create("Song").should be_an_instance_of(SongSerializer)
  end
  it "creates by lowercase string" do
    factory.create("song").should be_an_instance_of(SongSerializer)
  end
  it "creates by lowercase plural string" do
    factory.create("songs").should be_an_instance_of(SongSerializer)
  end
  it "creates by symbol" do
    factory.create(:song).should be_an_instance_of(SongSerializer)
  end
  it "creates by class" do
    factory.create(Song).should be_an_instance_of(SongSerializer)
  end

  it "creates multiple with Array" do
    serializers = factory.create("Song", "artists", :album)
    serializers[0].should be_an_instance_of(SongSerializer)
    serializers[1].should be_an_instance_of(ArtistSerializer)
    serializers[2].should be_an_instance_of(AlbumSerializer)
  end
end
