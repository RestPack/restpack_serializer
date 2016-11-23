require 'spec_helper'

describe RestPack::Serializer::SideLoading do
  context "invalid :include" do
    before(:each) do
      FactoryGirl.create(:song)
    end

    context "an include to an inexistent model" do
      it "raises an exception" do
        exception = RestPack::Serializer::InvalidInclude
        message = ":wrong is not a valid include for MyApp::Song"

        expect do
          MyApp::SongSerializer.side_loads([MyApp::Song.first], RestPack::Serializer::Options.new(MyApp::SongSerializer, "include" => "wrong"))
        end.to raise_error(exception, message)
      end
    end

    context "an include to a model which has not been whitelisted with 'can_include'" do
      it "raises an exception" do
        payment = FactoryGirl.create(:payment)
        exception = RestPack::Serializer::InvalidInclude
        message = ":payments is not a valid include for MyApp::Artist"

        expect do
          MyApp::ArtistSerializer.side_loads([payment.artist], RestPack::Serializer::Options.new(MyApp::ArtistSerializer, "include" => "payments"))
        end.to raise_error(exception, message)
      end
    end
  end

  describe "#can_include" do
    class CustomSerializer
      include RestPack::Serializer
      attributes :a, :b, :c
    end
    it "defaults to empty array" do
      expect(CustomSerializer.can_includes).to eq([])
    end

    it "allows includes to be specified" do
      class CustomSerializer
        can_include :model1
        can_include :model2, :model3
      end

      expect(CustomSerializer.can_includes).to eq([:model1, :model2, :model3])
    end
  end

  describe "#links" do
    it do
      expect(MyApp::AlbumSerializer.links).to eq(
        "albums.artist" => {
          href: "/artists/{albums.artist}",
          type: :artists
        },
        "albums.songs" => {
          href: "/songs?album_id={albums.id}",
          type: :songs
        }
      )
    end

    it "applies custom RestPack::Serializer.config.href_prefix" do
      original = RestPack::Serializer.config.href_prefix
      RestPack::Serializer.config.href_prefix = "/api/v1"
      expect(MyApp::AlbumSerializer.links["albums.artist"][:href]).to eq("/api/v1/artists/{albums.artist}")
      RestPack::Serializer.config.href_prefix = original
    end

    it "applies custom serializer  href_prefix" do
      original = RestPack::Serializer.config.href_prefix
      MyApp::AlbumSerializer.href_prefix = '/api/v2'
      expect(MyApp::AlbumSerializer.links["albums.artist"][:href]).to eq("/api/v2/artists/{albums.artist}")
      MyApp::AlbumSerializer.href_prefix = original
    end
  end

  describe "#filterable_by" do
    context "a model with no :belongs_to relations" do
      it "is filterable by :id only" do
        expect(MyApp::ArtistSerializer.filterable_by).to eq([:id])
      end
    end
    context "a model with a single :belongs_to relations" do
      it "is filterable by primary key and foreign keys" do
        expect(MyApp::AlbumSerializer.filterable_by).to eq([:id, :artist_id, :year])
      end
    end
    context "a model with multiple :belongs_to relations" do
      it "is filterable by primary key and foreign keys" do
        expect(MyApp::SongSerializer.filterable_by).to eq([:id, :artist_id, :album_id, :title])
      end
    end
  end
end
