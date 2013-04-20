require './spec/spec_helper'

describe RestPack::Serializer::SideLoading do
  context "when side-loading" do
    describe ".has_many" do

      before(:each) do
        FactoryGirl.create(:artist_with_albums, album_count: 2)
        FactoryGirl.create(:artist_with_albums, album_count: 1)
      end
      let(:side_loads) { ArtistSerializer.side_loads(models, options) }

      context "with a single model" do
        let(:models) { [Artist.first] }

        context "when including :albums" do
          let(:options) { { includes: [:albums] } }

          it "returns side-loaded albums" do
            pending "TODO: add support for filtering while paging"
            side_loads[:albums].count.should == 1
          end
        end
      end

    end
  end
end