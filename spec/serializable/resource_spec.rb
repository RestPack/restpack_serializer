require 'spec_helper'

describe RestPack::Serializer::Resource do
  before(:each) do
    @album = FactoryGirl.create(:album_with_songs, song_count: 11)
    @song = @album.songs.first
  end

  let(:resource) { MyApp::SongSerializer.resource(params, scope, context) }
  let(:params) { { id: @song.id } }
  let(:scope) { nil }
  let(:context) { { } }

  it "returns a resource by id" do
    resource[:songs].count.should == 1
    resource[:songs][0][:id].should == @song.id.to_s
  end

  context "with context" do
    let(:context) { { reverse_title?: true } }

    it "returns reversed titles" do
      resource[:songs][0][:title].should == @song.title.reverse
    end
  end

  describe "side-loading" do
    let(:params) { { id: @song.id, include: 'albums' } }

    it "includes side-loaded models" do
      resource[:linked][:albums].count.should == 1
      resource[:linked][:albums].first[:id].should == @song.album.id.to_s
    end

    it "includes the side-loads in the main meta data" do
      resource[:meta][:songs][:include].should == ["albums"]
    end
  end

  describe "missing resource" do
    let(:params) { { id: "-99" } }
    it "returns no resource" do
      resource[:songs].length.should == 0
    end

    #TODO: add specs for jsonapi error format when it has been standardised
    # https://github.com/RestPack/restpack_serializer/issues/27
    # https://github.com/json-api/json-api/issues/7
  end

  describe "song with no artist" do
    let(:song) { FactoryGirl.create(:song, :artist => nil) }
    let(:resource) { MyApp::SongSerializer.resource(id: song.id.to_s) }

    it "should not have an artist link" do
      resource[:songs][0][:links].keys.should_not include(:artist)
    end
  end
end
