require './spec/spec_helper'

describe RestPack::Serializer::SideLoading do
  before(:each) do
    FactoryGirl.create(:album_with_songs, song_count: 18)
  end
  let(:side_loads) { SongSerializer.side_loads(models, options) }

  context "with empty models" do
    let(:models) { [] }

    context "no side-loads" do
      let(:options) { {} }
      
      it "returns an empty hash" do
        side_loads.should == {}
      end
    end

    context "with single side-load" do
      let(:options) { { includes: [:albums] } }

      it "returns an empty hash" do
        side_loads.should == {}
      end
    end
  end

  context "with models" do
    let(:models) { [Song.first] }

    context "with single side-load" do
      let(:options) { { includes: [:albums] } }

      it "returns side-loaded albums" do
        side_loads.should == {
          albums: [AlbumSerializer.new.as_json(Song.first.album)]
        }
      end
    end
  end
end