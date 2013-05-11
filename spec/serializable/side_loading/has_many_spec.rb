require './spec/spec_helper'

describe RestPack::Serializer::SideLoading do
  context "when side-loading" do
    describe ".has_many" do

      before(:each) do
        @artist1 = FactoryGirl.create(:artist_with_albums, album_count: 2)
        @artist2 = FactoryGirl.create(:artist_with_albums, album_count: 1)
      end
      let(:side_loads) { ArtistSerializer.side_loads(models, options) }

      context "with a single model" do
        let(:models) { [@artist1] }

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(Artist, { "includes" => "albums" }) }

          it "returns side-loaded albums" do
            side_loads[:albums].count.should == @artist1.albums.count
            side_loads[:meta][:albums][:page].should == 1
            side_loads[:meta][:albums][:count].should == @artist1.albums.count
          end
        end
      end

      context "with two models" do
        let(:models) { [@artist1, @artist2] }

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(Artist, { "includes" => "albums" }) }

          it "returns side-loaded albums" do
            expected_count = @artist1.albums.count + @artist2.albums.count
            side_loads[:albums].count.should == expected_count
            side_loads[:meta][:albums][:count].should == expected_count
          end
        end
      end

    end
  end
end
