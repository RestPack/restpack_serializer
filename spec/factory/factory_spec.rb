require 'spec_helper'

describe RestPack::Serializer::Factory do
  let(:factory) { RestPack::Serializer::Factory }

  it "creates by string" do
    factory.create("Song").should be_an_instance_of(MyApp::SongSerializer)
  end
  it "creates by lowercase string" do
    factory.create("song").should be_an_instance_of(MyApp::SongSerializer)
  end
  it "creates by lowercase plural string" do
    factory.create("songs").should be_an_instance_of(MyApp::SongSerializer)
  end
  it "creates by symbol" do
    factory.create(:song).should be_an_instance_of(MyApp::SongSerializer)
  end
  it "creates by class" do
    factory.create(MyApp::Song).should be_an_instance_of(MyApp::SongSerializer)
  end
  it "creates by multiple words separated by underscore" do
    class OrderLineSerializer
      include RestPack::Serializer
      attributes :a, :b, :c
    end

    factory.create('order_lines').should be_an_instance_of(OrderLineSerializer)
  end

  it "creates multiple with Array" do
    serializers = factory.create("Song", "artists", :album)
    serializers[0].should be_an_instance_of(MyApp::SongSerializer)
    serializers[1].should be_an_instance_of(MyApp::ArtistSerializer)
    serializers[2].should be_an_instance_of(MyApp::AlbumSerializer)
  end
end
