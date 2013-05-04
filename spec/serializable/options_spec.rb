require './spec/spec_helper'

describe RestPack::Serializer::Options do
  let(:subject) { RestPack::Serializer::Options.new(Song, params) }

  describe "default values" do
    let(:params) { {} }
    it { subject.model_class.should == Song }
    it { subject.includes.should == [] }
    it { subject.page.should == 1 }
    it { subject.page_size.should == 10 }
    it { subject.filters.should == {} }
    it { subject.scope.should == Song.scoped }
  end

  context "with paging params" do
    let(:params) { { "page" => "2", "page_size" => "8" } }
    it { subject.page.should == 2 }
    it { subject.page_size.should == 8 }
  end

  context "with includes" do
    let(:params) { { "includes" => "model1,model2" } }
    it { subject.includes.should == [:model1, :model2] }
  end
end