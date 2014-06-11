require 'spec_helper'

describe RestPack::Serializer::Factory do
  let(:factory) { RestPack::Serializer::Factory }

  describe "single-word" do
    it "creates by string" do
      factory.create("Song").should be_an_instance_of(MyApp::SongSerializer)
    end
    it "creates by lowercase string" do
      factory.create("song").should be_an_instance_of(MyApp::SongSerializer)
    end
    it "creates by lowercase plural string" do
      factory.create("songs").should be_an_instance_of(MyApp::SongSerializer)
    end
    it "creates by symbol" do
      factory.create(:song).should be_an_instance_of(MyApp::SongSerializer)
    end
    it "creates by class" do
      factory.create(MyApp::Song).should be_an_instance_of(MyApp::SongSerializer)
    end

    it "creates multiple with Array" do
      serializers = factory.create("Song", "artists", :album)
      serializers[0].should be_an_instance_of(MyApp::SongSerializer)
      serializers[1].should be_an_instance_of(MyApp::ArtistSerializer)
      serializers[2].should be_an_instance_of(MyApp::AlbumSerializer)
    end
  end

  describe "multi-word" do
    it "creates multi-word string" do
      factory.create("AlbumReview").should be_an_instance_of(MyApp::AlbumReviewSerializer)
    end
    it "creates multi-word lowercase string" do
      factory.create("album_review").should be_an_instance_of(MyApp::AlbumReviewSerializer)
    end
    it "creates multi-word lowercase plural string" do
      factory.create("album_reviews").should be_an_instance_of(MyApp::AlbumReviewSerializer)
    end
    it "creates multi-word symbol" do
      factory.create(:album_review).should be_an_instance_of(MyApp::AlbumReviewSerializer)
    end
    it "creates multi-word class" do
      factory.create(MyApp::AlbumReview).should be_an_instance_of(MyApp::AlbumReviewSerializer)
    end
  end

end
