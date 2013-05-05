require './spec/spec_helper'

describe RestPack::Serializer::SideLoading do
  context "invalid :includes" do
    before(:each) do
      FactoryGirl.create(:song)
    end

    it "raises an exception" do
      exception = RestPack::Serializer::InvalidInclude
      message = ":wrong is not a valid include for Song"

      expect do
        SongSerializer.side_loads([Song.first], RestPack::Serializer::Options.new(Song, { "includes" => "wrong" }))
      end.to raise_error(exception, message)
    end
  end

  describe "#filterable_by" do
    context "a model with no :belongs_to relations" do
      it "is filterable by :id only" do
        ArtistSerializer.filterable_by.should == [:id]
      end
    end
    context "a model with a single :belongs_torelations" do
      it "is filterable by primary key and foreign keys" do
        AlbumSerializer.filterable_by.should =~ [:id, :artist_id]
      end
    end
    context "a model with multiple :belongs_to relations" do
      it "is filterable by primary key and foreign keys" do
        SongSerializer.filterable_by.should =~ [:id, :artist_id, :album_id]
      end
    end
  end
end