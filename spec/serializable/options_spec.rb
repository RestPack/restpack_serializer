require './spec/spec_helper'

describe RestPack::Serializer::Options do
  let(:subject) { RestPack::Serializer::Options.new(SongSerializer, params, scope) }
  let(:params) { {} }
  let(:scope) { nil }

  describe 'default values' do
    it { subject.model_class.should == Song }
    it { subject.includes.should == [] }
    it { subject.page.should == 1 }
    it { subject.page_size.should == 10 }
    it { subject.filters.should == {} }
    it { subject.scope.should == Song.scoped }
    it { subject.default_page_size?.should == true }
    it { subject.filters_as_url_params.should == '' }
  end

  describe 'with paging params' do
    let(:params) { { 'page' => '2', 'page_size' => '8' } }
    it { subject.page.should == 2 }
    it { subject.page_size.should == 8 }
  end

  describe 'with includes' do
    let(:params) { { 'includes' => 'model1,model2' } }
    it { subject.includes.should == [:model1, :model2] }
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

  context 'scopes' do
    describe 'with default scope' do
      it { subject.scope.should == Song.scoped }
    end

    describe 'with custom scope' do
      let(:scope) { Song.where("id >= 100") }
      it { subject.scope.should == scope }
    end
  end
end
