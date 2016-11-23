require 'spec_helper'

describe RestPack::Serializer::Resource do
  before(:each) do
    @album = FactoryGirl.create(:album_with_songs, song_count: 11)
    @song = @album.songs.first
  end

  let(:resource) { MyApp::SongSerializer.resource(params, scope, context) }
  let(:params) { { id: @song.id } }
  let(:scope) { nil }
  let(:context) { {} }

  it "returns a resource by id" do
    expect(resource[:songs].count).to eq(1)
    expect(resource[:songs][0][:id]).to eq(@song.id.to_s)
  end

  context "with context" do
    let(:context) { { reverse_title?: true } }

    it "returns reversed titles" do
      expect(resource[:songs][0][:title]).to eq(@song.title.reverse)
    end
  end

  describe "side-loading" do
    let(:params) { { id: @song.id, include: 'albums' } }

    it "includes side-loaded models" do
      expect(resource[:linked][:albums].count).to eq(1)
      expect(resource[:linked][:albums].first[:id]).to eq(@song.album.id.to_s)
    end

    it "includes the side-loads in the main meta data" do
      expect(resource[:meta][:songs][:include]).to eq(%w(albums))
    end
  end

  describe "missing resource" do
    let(:params) { { id: "-99" } }

    it "returns no resource" do
      expect(resource[:songs].length).to eq(0)
    end

    #TODO: add specs for jsonapi error format when it has been standardised
    # https://github.com/RestPack/restpack_serializer/issues/27
    # https://github.com/json-api/json-api/issues/7
  end

  describe "song with no artist" do
    let(:song) { FactoryGirl.create(:song, artist: nil) }
    let(:resource) { MyApp::SongSerializer.resource(id: song.id.to_s) }

    it "should not have an artist link" do
      expect(resource[:songs][0][:links].keys).not_to include(:artist)
    end
  end
end
