require './spec/spec_helper'

describe RestPack::Serializer::SideLoading do
  context "when side-loading" do
    describe ".belongs_to" do

      before(:each) do
        FactoryGirl.create(:artist_with_albums, album_count: 2)
        FactoryGirl.create(:artist_with_albums, album_count: 1)
      end
      let(:side_loads) { SongSerializer.side_loads(models, options) }

      context "with no models" do
        let(:models) { [] }

        context "no side-loads" do
          let(:options) { {} }

          it "returns an empty hash" do
            side_loads.should == {}
          end
        end

        context "when including :albums" do
          let(:options) { { includes: [:albums] } }

          it "returns an empty hash" do
            side_loads.should == {}
          end
        end
      end

      context "with a single model" do
        let(:models) { [Song.first] }

        context "when including :albums" do
          let(:options) { { includes: [:albums] } }

          it "returns side-loaded albums" do
            side_loads.should == {
              albums: [AlbumSerializer.new.as_json(Song.first.album)]
            }
          end
        end
      end

      context "with multiple models" do
        let(:artist1) { Artist.find(1) }
        let(:artist2) { Artist.find(2) }
        let(:song1) { artist1.songs.first }
        let(:song2) { artist2.songs.first }
        let(:models) { [song1, song2] }

        context "when including :albums" do
          let(:options) { { includes: [:albums] } }

          it "returns side-loaded albums" do
            side_loads.should == {
              albums: [
                AlbumSerializer.new.as_json(song1.album),
                AlbumSerializer.new.as_json(song2.album)
              ]
            }
          end
        end
      end

    end
  end
end