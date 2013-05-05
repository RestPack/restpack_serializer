require './spec/spec_helper'

describe RestPack::Serializer::Options do
  let(:subject) { RestPack::Serializer::Options.new(Song, params) }

  describe 'default values' do
    let(:params) { {} }
    it { subject.model_class.should == Song }
    it { subject.includes.should == [] }
    it { subject.page.should == 1 }
    it { subject.page_size.should == 10 }
    it { subject.filters.should == {} }
    it { subject.scope.should == Song.scoped }
  end

  context 'with paging params' do
    let(:params) { { 'page' => '2', 'page_size' => '8' } }
    it { subject.page.should == 2 }
    it { subject.page_size.should == 8 }
  end

  context 'with includes' do
    let(:params) { { 'includes' => 'model1,model2' } }
    it { subject.includes.should == [:model1, :model2] }
  end

  describe 'with filters' do
    context 'with no filter params' do
      let(:params) { { } }
      it { subject.filters.should == {} }
    end
    context 'with a primary key with a single value' do
      let(:params) { { 'id' => '142857' } }
      it { subject.filters.should == { id: ['142857'] } }
    end
    context 'with a primary key with multiple values' do
      let(:params) { { 'ids' => '42,142857' } }
      it { subject.filters.should == { id: ['42', '142857'] } }
    end
    context 'with a foreign key with a single value' do
      let(:params) { { 'album_id' => '789' } }
      it { subject.filters.should == { album_id: ['789'] } }
    end
    context 'with a foreign key with multiple values' do
      let(:params) { { 'album_id' => '789,678,567' } }
      it { subject.filters.should == { album_id: ['789', '678', '567'] } }
    end
    context 'with multiple foreign keys' do
      let(:params) { { 'album_id' => '111,222', 'artist_id' => '888,999' } }
      it { subject.filters.should == { album_id: ['111', '222'], artist_id: ['888', '999'] } }
    end
  end
end