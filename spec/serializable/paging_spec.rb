require 'spec_helper'

describe RestPack::Serializer::Paging do
  before(:each) do
    @album1 = FactoryGirl.create(:album_with_songs, song_count: 11)
    @album2 = FactoryGirl.create(:album_with_songs, song_count: 7)
  end

  context "#page" do
    let(:page) { MyApp::SongSerializer.page(params, scope, context) }
    let(:params) { {} }
    let(:scope) { nil }
    let(:context) { {} }

    context "with defaults" do
      it "page defaults to 1" do
        expect(page[:meta][:songs][:page]).to eq(1)
      end

      it "page_size defaults to 10" do
        expect(page[:meta][:songs][:page_size]).to eq(10)
      end

      it "includes valid paging meta data" do
        expect(page[:meta][:songs][:count]).to eq(18)
        expect(page[:meta][:songs][:page_count]).to eq(2)
        expect(page[:meta][:songs][:first_href]).to eq('/songs')
        expect(page[:meta][:songs][:previous_page]).to eq(nil)
        expect(page[:meta][:songs][:previous_href]).to eq(nil)
        expect(page[:meta][:songs][:next_page]).to eq(2)
        expect(page[:meta][:songs][:next_href]).to eq('/songs?page=2')
        expect(page[:meta][:songs][:last_href]).to eq('/songs?page=2')
      end

      it "includes links" do
        expect(page[:links]).to eq(
          'songs.album' => { href: "/albums/{songs.album}", type: :albums },
          'songs.artist' => { href: "/artists/{songs.artist}", type: :artists }
        )
      end
    end

    context 'when href prefix is set' do
      before do
        @original_prefix = MyApp::SongSerializer.href_prefix
        MyApp::SongSerializer.href_prefix = '/api/v3'
      end
      after { MyApp::SongSerializer.href_prefix = @original_prefix }

      let(:page) { MyApp::SongSerializer.page(params, scope, context) }

      it 'should use prefixed links' do
        expect(page[:meta][:songs][:next_href]).to eq('/api/v3/songs?page=2')
      end
    end

    context "with custom page size" do
      let(:params) { { page_size: '3' } }

      it "returns custom page sizes" do
        expect(page[:meta][:songs][:page_size]).to eq(3)
        expect(page[:meta][:songs][:page_count]).to eq(6)
      end

      it "includes the custom page size in the page hrefs" do
        expect(page[:meta][:songs][:next_page]).to eq(2)
        expect(page[:meta][:songs][:next_href]).to eq('/songs?page=2&page_size=3')
        expect(page[:meta][:songs][:last_href]).to eq('/songs?page=6&page_size=3')
      end
    end

    context "with custom filter" do
      context "valid :title" do
        let(:params) { { title: @album1.songs[0].title } }

        it "returns the album" do
          expect(page[:meta][:songs][:count]).to eq(1)
        end
      end

      context "invalid :title" do
        let(:params) { { title: "this doesn't exist" } }

        it "returns the album" do
          expect(page[:meta][:songs][:count]).to eq(0)
        end
      end
    end

    context "with context" do
      let(:context) { { reverse_title?: true } }

      it "returns reversed titles" do
        first = MyApp::Song.first
        expect(page[:songs].first[:title]).to eq(first.title.reverse)
      end
    end

    it "serializes results" do
      first = MyApp::Song.first
      expect(page[:songs].first).to eq(
        id: first.id.to_s,
        title: first.title,
        album_id: first.album_id,
        links: {
          album: first.album_id.to_s,
          artist: first.artist_id.to_s
        }
      )
    end

    context "first page" do
      let(:params) { { page: '1' } }

      it "returns first page" do
        expect(page[:meta][:songs][:page]).to eq(1)
        expect(page[:meta][:songs][:page_size]).to eq(10)
        expect(page[:meta][:songs][:previous_page]).to eq(nil)
        expect(page[:meta][:songs][:next_page]).to eq(2)
      end
    end

    context "second page" do
      let(:params) { { page: '2' } }

      it "returns second page" do
        expect(page[:songs].length).to eq(8)
        expect(page[:meta][:songs][:page]).to eq(2)
        expect(page[:meta][:songs][:previous_page]).to eq(1)
        expect(page[:meta][:songs][:next_page]).to eq(nil)
        expect(page[:meta][:songs][:previous_href]).to eq('/songs')
      end
    end

    context "when sideloading" do
      let(:params) { { include: 'albums' } }

      it "includes side-loaded models" do
        expect(page[:linked][:albums]).not_to eq(nil)
      end

      it "includes the side-loads in the main meta data" do
        expect(page[:meta][:songs][:include]).to eq(%w(albums))
      end

      it "includes the side-loads in page hrefs" do
        expect(page[:meta][:songs][:next_href]).to eq('/songs?page=2&include=albums')
      end

      it "includes links between documents" do
        song = page[:songs].first
        song_model = MyApp::Song.find(song[:id])
        expect(song[:links][:album]).to eq(song_model.album_id.to_s)
        expect(song[:links][:artist]).to eq(song_model.artist_id.to_s)

        album = page[:linked][:albums].first
        album_model = MyApp::Album.find(album[:id])

        expect(album[:links][:artist]).to eq(album_model.artist_id.to_s)
        expect((page[:songs].map { |song| song[:id] } - album[:links][:songs]).empty?).to eq(true)
      end

      context "with includes as comma delimited string" do
        let(:params) { { include: "albums,artists" } }

        it "includes side-loaded models" do
          expect(page[:linked][:albums]).not_to eq(nil)
          expect(page[:linked][:artists]).not_to eq(nil)
        end

        it "includes the side-loads in page hrefs" do
          expect(page[:meta][:songs][:next_href]).to eq('/songs?page=2&include=albums,artists')
        end

        it "includes links" do
          expect(page[:links]['songs.album']).not_to eq(nil)
          expect(page[:links]['songs.artist']).not_to eq(nil)
          expect(page[:links]['albums.songs']).not_to eq(nil)
          expect(page[:links]['albums.artist']).not_to eq(nil)
          expect(page[:links]['artists.songs']).not_to eq(nil)
          expect(page[:links]['artists.albums']).not_to eq(nil)
        end
      end
    end

    context "when filtering" do
      context "with no filters" do
        let(:params) { {} }

        it "returns a page of all data" do
          expect(page[:meta][:songs][:count]).to eq(18)
        end
      end

      context "with :album_id filter" do
        let(:params) { { album_id: @album1.id.to_s } }

        it "returns a page with songs from album1" do
          expect(page[:meta][:songs][:count]).to eq(@album1.songs.length)
        end

        it "includes the filter in page hrefs" do
          expect(page[:meta][:songs][:next_href]).to eq("/songs?page=2&album_id=#{@album1.id}")
        end
      end
    end

    context 'when sorting' do
      context 'with no sorting' do
        let(:params) { {} }

        it "uses the model's sorting" do
          expect(page[:songs].first[:id].to_i < page[:songs].last[:id].to_i).to eq(true)
        end
      end

      context 'with descending title sorting' do
        let(:params) { { sort: '-title' } }

        it 'returns a page with sorted songs' do
          expect(page[:songs].first[:title] > page[:songs].last[:title]).to eq(true)
        end

        it 'includes the sorting in page hrefs' do
          expect(page[:meta][:songs][:next_href]).to eq('/songs?page=2&sort=-title')
        end
      end
    end

    context "with custom scope" do
      before do
        FactoryGirl.create(:album, year: 1930)
        FactoryGirl.create(:album, year: 1948)
      end
      let(:page) { MyApp::AlbumSerializer.page(params, scope) }
      let(:scope) { MyApp::Album.classic }

      it "returns a page of scoped data" do
        expect(page[:meta][:albums][:count]).to eq(2)
      end
    end
  end

  context "#page_with_options" do
    let(:page) { MyApp::SongSerializer.page_with_options(options) }
    let(:params) { {} }
    let(:options) { RestPack::Serializer::Options.new(MyApp::SongSerializer, params) }

    context "with defaults" do
      it "includes valid paging meta data" do
        expect(page[:meta][:songs][:count]).to eq(18)
        expect(page[:meta][:songs][:page_count]).to eq(2)
        expect(page[:meta][:songs][:previous_page]).to eq(nil)
        expect(page[:meta][:songs][:next_page]).to eq(2)
      end
    end

    context "with custom page size" do
      let(:params) { { page_size: '3' } }

      it "returns custom page sizes" do
        expect(page[:meta][:songs][:page_size]).to eq(3)
        expect(page[:meta][:songs][:page_count]).to eq(6)
      end
    end
  end

  context "paging with paged side-load" do
    let(:page) { MyApp::AlbumSerializer.page_with_options(options) }
    let(:options) { RestPack::Serializer::Options.new(MyApp::AlbumSerializer, include: 'songs') }

    it "includes side-loaded paging data in meta data" do
      expect(page[:meta][:albums]).not_to eq(nil)
      expect(page[:meta][:albums][:page]).to eq(1)
      expect(page[:meta][:songs]).not_to eq(nil)
      expect(page[:meta][:songs][:page]).to eq(1)
    end
  end

  context "paging with two paged side-loads" do
    let(:page) { MyApp::ArtistSerializer.page_with_options(options) }
    let(:options) { RestPack::Serializer::Options.new(MyApp::ArtistSerializer, include: 'albums,songs') }

    it "includes side-loaded paging data in meta data" do
      expect(page[:meta][:albums]).not_to eq(nil)
      expect(page[:meta][:albums][:page]).to eq(1)
      expect(page[:meta][:songs]).not_to eq(nil)
      expect(page[:meta][:songs][:page]).to eq(1)
    end
  end
end
