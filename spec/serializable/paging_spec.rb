require './spec/spec_helper'

describe RestPack::Serializer::Paging do
  before(:each) do
    @album1 = FactoryGirl.create(:album_with_songs, song_count: 11)
    @album2 = FactoryGirl.create(:album_with_songs, song_count: 7)
  end

  context "#page" do
    let(:page) { SongSerializer.page(params) }
    let(:params) { { } }

    context "with defaults" do
      it "page defaults to 1" do
        page[:songs_meta][:page].should == 1
      end
      it "page_size defaults to 10" do
        page[:songs_meta][:page_size].should == 10
      end
      it "includes valid paging meta data" do
        page[:songs_meta][:count].should == 18
        page[:songs_meta][:page_count].should == 2
        page[:songs_meta][:previous_page].should == nil
        page[:songs_meta][:next_page].should == 2
      end
    end

    context "with custom page size" do
      let(:params) { { page_size: 3 } }
      it "returns custom page sizes" do
        page[:songs_meta][:page_size].should == 3
        page[:songs_meta][:page_count].should == 6
      end
    end

    it "serializes results" do
      first = Song.first
      page[:songs].first.should == {
        id: first.id,
        title: first.title,
        album_id: first.album_id
      }
    end

    context "first page" do
      let(:params) { { page: 1 } }

      it "returns first page" do
        page[:songs_meta][:page].should == 1
        page[:songs_meta][:page_size].should == 10
        page[:songs_meta][:previous_page].should == nil
        page[:songs_meta][:next_page].should == 2
      end
    end

    context "second page" do
      let(:params) { { page: 2 } }

      it "returns second page" do
        page[:songs_meta][:page].should == 2
        page[:songs].length.should == 8
        page[:songs_meta][:previous_page].should == 1
        page[:songs_meta][:next_page].should == nil
      end
    end

    context "when sideloading" do
      let(:params) { { includes: 'albums' } }

      it "includes side-loaded models" do
        page[:albums].should_not == nil
      end

      it "includes the side-loads in the main meta data" do
        page[:songs_meta][:includes].should == [:albums]
      end

      context "with includes as comma delimited string" do
        let(:params) { { includes: "albums,artists" } }
        it "includes side-loaded models" do
          page[:albums].should_not == nil
          page[:artists].should_not == nil
        end
      end
    end

    context "when filtering" do
      context "with no filters" do
        let(:params) do
          { }
        end

        it "returns a page of all data" do
          page[:songs_meta][:count].should == 18
        end
      end

      context "with :album_id filter" do
        let(:params) do
          { album_id: @album1.id }
        end

        it "returns a page with songs from album1" do
          page[:songs_meta][:count].should == @album1.songs.length
        end
      end

      context "with :album_id and :title filters" do
        let(:params) do
          {
            album_id: @album1.id,
            title: @album1.songs.first.title
          }
        end

        it "returns a single song" do
          page[:songs_meta][:count].should == 1
        end
      end

    end
  end

  context "#page_with_options" do
    let(:page) { SongSerializer.page_with_options(options) }
    let(:params) { {} }
    let(:options) { RestPack::Serializer::Options.new(Song, params) }

    context "with defaults" do
      it "includes valid paging meta data" do
        page[:songs_meta][:count].should == 18
        page[:songs_meta][:page_count].should == 2
        page[:songs_meta][:previous_page].should == nil
        page[:songs_meta][:next_page].should == 2
      end
    end

    context "with custom page size" do
      let(:params) { { page_size: 3 } }
      it "returns custom page sizes" do
        page[:songs_meta][:page_size].should == 3
        page[:songs_meta][:page_count].should == 6
      end
    end
  end
end