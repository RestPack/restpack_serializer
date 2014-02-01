require 'spec_helper'

describe RestPack::Serializer::Single do
  before(:each) do
    @album = FactoryGirl.create(:album_with_songs, song_count: 11)
    @song = @album.songs.first
  end

  let(:resource) { MyApp::SongSerializer.single(params, scope, context) }
  let(:params) { { id: @song.id } }
  let(:scope) { nil }
  let(:context) { { } }

  it "returns a resource by id" do
    resource[:id].should == @song.id.to_s
    resource[:title].should == @song.title
  end

  context "with context" do
    let(:context) { { reverse_title?: true } }

    it "returns reversed titles" do
      resource[:title].should == @song.title.reverse
    end
  end

  context "invalid id" do
    let(:params) { { id: @song.id + 100 } }

    it "returns nil" do
      resource.should == nil
    end
  end
end
