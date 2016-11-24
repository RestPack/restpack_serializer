require 'spec_helper'

describe RestPack::Serializer::Options do
  let(:subject) { RestPack::Serializer::Options.new(MyApp::SongSerializer, params, scope) }
  let(:params) { {} }
  let(:scope) { nil }

  describe 'default values' do
    it { expect(subject.model_class).to eq(MyApp::Song) }
    it { expect(subject.include).to eq([]) }
    it { expect(subject.page).to eq(1) }
    it { expect(subject.page_size).to eq(10) }
    it { expect(subject.filters).to eq({}) }
    it { expect(subject.scope).to eq(MyApp::Song.all) }
    it { expect(subject.default_page_size?).to eq(true) }
    it { expect(subject.filters_as_url_params).to eq('') }
  end

  describe 'with paging params' do
    let(:params) { { 'page' => '2', 'page_size' => '8' } }
    it { expect(subject.page).to eq(2) }
    it { expect(subject.page_size).to eq(8) }
  end

  describe 'with include' do
    let(:params) { { 'include' => 'model1,model2' } }
    it { expect(subject.include).to eq(%w(model1 model2)) }
  end

  context 'with filters' do
    describe 'with no filter params' do
      let(:params) { {} }
      it { expect(subject.filters).to eq({}) }
    end

    describe 'with a primary key with a single value' do
      let(:params) { { 'id' => '142857' } }
      it { expect(subject.filters).to eq(id: %w(142857)) }
      it { expect(subject.filters_as_url_params).to eq('id=142857') }
    end

    describe 'with a primary key with multiple values' do
      let(:params) { { 'ids' => '42,142857' } }
      it { expect(subject.filters).to eq(id: %w(42 142857)) }
      it { expect(subject.filters_as_url_params).to eq('id=42,142857') }
    end

    describe 'with a foreign key with a single value' do
      let(:params) { { 'album_id' => '789' } }
      it { expect(subject.filters).to eq(album_id: %w(789)) }
      it { expect(subject.filters_as_url_params).to eq('album_id=789') }
    end

    describe 'with a foreign key with multiple values' do
      let(:params) { { 'album_id' => '789,678,567' } }
      it { expect(subject.filters).to eq(album_id: %w(789 678 567)) }
      it { expect(subject.filters_as_url_params).to eq('album_id=789,678,567') }
    end

    describe 'with multiple foreign keys' do
      let(:params) { { 'album_id' => '111,222', 'artist_id' => '888,999' } }
      it { expect(subject.filters).to eq(album_id: %w(111 222), artist_id: %w(888 999)) }
      it { expect(subject.filters_as_url_params).to eq('album_id=111,222&artist_id=888,999') }
    end
  end

  context 'with sorting parameters' do
    describe 'with no params' do
      let(:params) { {} }
      it { expect(subject.sorting).to eq({}) }
    end
    describe 'with a sorting value' do
      let(:params) { { 'sort' => 'Title' } }
      it { expect(subject.sorting).to eq(title: :asc) }
      it { expect(subject.sorting_as_url_params).to eq('sort=title') }
    end
    describe 'with a descending sorting value' do
      let(:params) { { 'sort' => '-title' } }
      it { expect(subject.sorting).to eq(title: :desc) }
      it { expect(subject.sorting_as_url_params).to eq('sort=-title') }
    end
    describe 'with multiple sorting values' do
      let(:params) { { 'sort' => '-Title,ID' } }
      it { expect(subject.sorting).to eq(title: :desc, id: :asc) }
      it { expect(subject.sorting_as_url_params).to eq('sort=-title,id') }
    end
    describe 'with a not allowed sorting value' do
      let(:params) { { 'sort' => '-title,album_id,id' } }
      it { expect(subject.sorting).to eq(title: :desc, id: :asc) }
      it { expect(subject.sorting_as_url_params).to eq('sort=-title,id') }
    end
  end

  context 'scopes' do
    describe 'with default scope' do
      it { expect(subject.scope).to eq(MyApp::Song.all) }
    end

    describe 'with custom scope' do
      let(:scope) { MyApp::Song.where("id >= 100") }
      it { expect(subject.scope).to eq(scope) }
    end
  end
end
