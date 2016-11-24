require 'spec_helper'

describe RestPack::Serializer::Factory do
  let(:factory) { RestPack::Serializer::Factory }

  describe "single-word" do
    it "creates by string" do
      expect(factory.create("Song")).to be_an_instance_of(MyApp::SongSerializer)
    end

    it "creates by lowercase string" do
      expect(factory.create("song")).to be_an_instance_of(MyApp::SongSerializer)
    end

    it "creates by lowercase plural string" do
      expect(factory.create("songs")).to be_an_instance_of(MyApp::SongSerializer)
    end

    it "creates by symbol" do
      expect(factory.create(:song)).to be_an_instance_of(MyApp::SongSerializer)
    end

    it "creates by class" do
      expect(factory.create(MyApp::Song)).to be_an_instance_of(MyApp::SongSerializer)
    end

    it "creates multiple with Array" do
      serializers = factory.create("Song", "artists", :album)
      expect(serializers[0]).to be_an_instance_of(MyApp::SongSerializer)
      expect(serializers[1]).to be_an_instance_of(MyApp::ArtistSerializer)
      expect(serializers[2]).to be_an_instance_of(MyApp::AlbumSerializer)
    end
  end

  describe "multi-word" do
    it "creates multi-word string" do
      expect(factory.create("AlbumReview")).to be_an_instance_of(MyApp::AlbumReviewSerializer)
    end

    it "creates multi-word lowercase string" do
      expect(factory.create("album_review")).to be_an_instance_of(MyApp::AlbumReviewSerializer)
    end

    it "creates multi-word lowercase plural string" do
      expect(factory.create("album_reviews")).to be_an_instance_of(MyApp::AlbumReviewSerializer)
    end

    it "creates multi-word symbol" do
      expect(factory.create(:album_review)).to be_an_instance_of(MyApp::AlbumReviewSerializer)
    end

    it "creates multi-word class" do
      expect(factory.create(MyApp::AlbumReview)).to be_an_instance_of(MyApp::AlbumReviewSerializer)
    end
  end
end
