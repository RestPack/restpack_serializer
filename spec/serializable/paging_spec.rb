require './spec/spec_helper'

describe RestPack::Serializable::Paging do
  class SongSerializer
    include RestPack::Serializable
    attributes :title, :album_id
  end

  context "when paging" do
    let(:options) { { } }
    let(:page) { SongSerializer.page(options) }

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
        #TODO: GJ: test for :previous_page and :next_page
      end
    end

    it "serializes results" do
      page[:songs].first.should == {
        title: 'Bloom',
        album_id: 8
      }
    end

    context "first page" do
      let(:options) { { page: 1 } }

      it "returns first page" do
        page[:songs_meta][:page].should == 1
        page[:songs_meta][:page_size].should == 10
      end
    end

    context "second page" do
      let(:options) { { page: 2 } }

      it "returns second page" do
        page[:songs_meta][:page].should == 2
        page[:songs].length.should == 8
      end
    end
  end
end