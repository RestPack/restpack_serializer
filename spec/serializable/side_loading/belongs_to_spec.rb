require 'spec_helper'

describe RestPack::Serializer::SideLoading do
  context "when side-loading" do
    describe ".belongs_to" do

      before(:each) do
        FactoryBot.create(:artist_with_albums, album_count: 2)
        FactoryBot.create(:artist_with_albums, album_count: 1)
      end
      let(:side_loads) { MyApp::SongSerializer.side_loads(models, options) }

      context "with no models" do
        let(:models) { [] }

        context "no side-loads" do
          let(:options) { RestPack::Serializer::Options.new(MyApp::SongSerializer) }

          it "returns a hash with no data" do
            expect(side_loads).to eq(meta: {})
          end
        end

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(MyApp::SongSerializer, "include" => "albums") }

          it "returns a hash with no data" do
            expect(side_loads).to eq(meta: {})
          end
        end
      end

      context "with a single model" do
        let(:models) { [MyApp::Song.first] }

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(MyApp::SongSerializer, "include" => "albums") }

          it "returns side-loaded albums" do
            expect(side_loads).to eq(
              albums: [MyApp::AlbumSerializer.as_json(MyApp::Song.first.album)],
              meta: {}
            )
          end
        end
      end

      context "with multiple models" do
        let(:artist1) { MyApp::Artist.find(1) }
        let(:artist2) { MyApp::Artist.find(2) }
        let(:song1) { artist1.songs.first }
        let(:song2) { artist2.songs.first }
        let(:models) { [song1, song2] }

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(MyApp::SongSerializer, "include" => "albums") }

          it "returns side-loaded albums" do
            expect(side_loads).to eq(
              albums: [
                MyApp::AlbumSerializer.as_json(song1.album),
                MyApp::AlbumSerializer.as_json(song2.album)
              ],
              meta: {}
            )
          end
        end
      end

      context 'without an associated model' do
        let!(:b_side) { FactoryBot.create(:song, album: nil) }
        let(:models) { [b_side] }

        context 'when including :albums' do
          let(:options) { RestPack::Serializer::Options.new(MyApp::SongSerializer, "include" => "albums") }

          it 'return a hash with no data' do
            expect(side_loads).to eq(
              albums: [],
              meta: {}
            )
          end
        end
      end

    end
  end
end
