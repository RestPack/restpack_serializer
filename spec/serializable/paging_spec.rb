require './spec/spec_helper'

describe RestPack::Serializer::Paging do

  context "when paging" do
    before(:each) do
      FactoryGirl.create(:album_with_songs, song_count: 18)
    end
    let(:page) { SongSerializer.page(options) }
    let(:options) { { } }

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

    it "serializes results" do
      first = Song.first
      page[:songs].first.should == {
        id: first.id,
        title: first.title,
        album_id: first.album_id
      }
    end

    context "first page" do
      let(:options) { { page: 1 } }

      it "returns first page" do
        page[:songs_meta][:page].should == 1
        page[:songs_meta][:page_size].should == 10
        page[:songs_meta][:previous_page].should == nil
        page[:songs_meta][:next_page].should == 2
      end
    end

    context "second page" do
      let(:options) { { page: 2 } }

      it "returns second page" do
        page[:songs_meta][:page].should == 2
        page[:songs].length.should == 8
        page[:songs_meta][:previous_page].should == 1
        page[:songs_meta][:next_page].should == nil
      end
    end

    context "when sideloading" do
      let(:options) { { includes: [:albums] } }

      it "includes side-loaded models" do
        page[:albums].should_not == nil
      end
    end
  end
end