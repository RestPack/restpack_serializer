require 'spec_helper'

describe RestPack::Serializer::Options do
  let(:subject) { RestPack::Serializer::Options.new(MyApp::SongSerializer, params, scope) }
  let(:params) { {} }
  let(:scope) { nil }

  describe 'default values' do
    it { subject.model_class.should == MyApp::Song }
    it { subject.include.should == [] }
    it { subject.page.should == 1 }
    it { subject.page_size.should == 10 }
    it { subject.filters.should == {} }
    it { subject.scope.should == MyApp::Song.all }
    it { subject.default_page_size?.should == true }
    it { subject.filters_as_url_params.should == '' }
  end

  describe 'with paging params' do
    let(:params) { { 'page' => '2', 'page_size' => '8' } }
    it { subject.page.should == 2 }
    it { subject.page_size.should == 8 }
  end

  describe 'with include' do
    let(:params) { { 'include' => 'model1,model2' } }
    it { subject.include.should == [:model1, :model2] }
  end

  context 'with filters' do
    describe 'with no filter params' do
      let(:params) { { } }
      it { subject.filters.should == {} }
    end
    describe 'with a primary key with a single value' do
      let(:params) { { 'id' => '142857' } }
      it { subject.filters.should == { id: ['142857'] } }
      it { subject.filters_as_url_params.should == 'id=142857' }
    end
    describe 'with a primary key with multiple values' do
      let(:params) { { 'ids' => '42,142857' } }
      it { subject.filters.should == { id: ['42', '142857'] } }
      it { subject.filters_as_url_params.should == 'id=42,142857' }
    end
    describe 'with a foreign key with a single value' do
      let(:params) { { 'album_id' => '789' } }
      it { subject.filters.should == { album_id: ['789'] } }
      it { subject.filters_as_url_params.should == 'album_id=789' }
    end
    describe 'with a foreign key with multiple values' do
      let(:params) { { 'album_id' => '789,678,567' } }
      it { subject.filters.should == { album_id: ['789', '678', '567'] } }
      it { subject.filters_as_url_params.should == 'album_id=789,678,567' }
    end
    describe 'with multiple foreign keys' do
      let(:params) { { 'album_id' => '111,222', 'artist_id' => '888,999' } }
      it { subject.filters.should == { album_id: ['111', '222'], artist_id: ['888', '999'] } }
      it { subject.filters_as_url_params.should == 'album_id=111,222&artist_id=888,999' }
    end
  end

  context 'with sorting parameters' do
    describe 'with no params' do
      let(:params) { { } }
      it { subject.sorting.should == {} }
    end
    describe 'with a sorting value' do
      let(:params) { { 'sort' => 'Title' } }
      it { subject.sorting.should == { title: :asc } }
      it { subject.sorting_as_url_params.should == 'sort=title' }
    end
    describe 'with a descending sorting value' do
      let(:params) { { 'sort' => '-title' } }
      it { subject.sorting.should == { title: :desc } }
      it { subject.sorting_as_url_params.should == 'sort=-title' }
    end
    describe 'with multiple sorting values' do
      let(:params) { { 'sort' => '-Title,ID' } }
      it { subject.sorting.should == { title: :desc, id: :asc } }
      it { subject.sorting_as_url_params.should == 'sort=-title,id' }
    end
    describe 'with a not allowed sorting value' do
      let(:params) { { 'sort' => '-title,album_id,id' } }
      it { subject.sorting.should == { title: :desc, id: :asc } }
      it { subject.sorting_as_url_params.should == 'sort=-title,id' }
    end
  end

  context 'scopes' do
    describe 'with default scope' do
      it { subject.scope.should == MyApp::Song.all }
    end

    describe 'with custom scope' do
      let(:scope) { MyApp::Song.where("id >= 100") }
      it { subject.scope.should == scope }
    end
  end
end
