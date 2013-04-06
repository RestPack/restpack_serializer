require './spec/spec_helper'

describe RestPack::Serializable::Paging do
  class SongSerializer
    include RestPack::Serializable
    attributes :title, :album_id
  end

  context "when paging" do
    context "first page" do
      before do
        @scope = Song.scoped
        @options = { page: 1, page_size: 10 }
        @page = SongSerializer.page(@scope, @options)
      end

      it "includes the first page of data" do
        @page[:songs].length.should == @options[:page_size]
      end

      it "includes valid meta data" do
        @page[:songs_meta].should_not == nil
        @page[:songs_meta][:page].should == 1
        @page[:songs_meta][:page_size].should == 10
        @page[:songs_meta][:count].should == 18
        @page[:songs_meta][:page_count].should == 2
        #TODO: GJ: test for :previous_page and :next_page
      end
    end
  end
end