require 'spec_helper'

describe RestPack::Serializer::SideLoading do
  context "when side-loading" do
    describe ".has_many_through" do

      before(:each) do
        @tag = FactoryGirl.create(:tag)
      end
      let(:side_loads) { MyApp::TagSerializer.side_loads(models, options) }

      context "with a single model" do
        let(:models) { [@tag] }

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(MyApp::TagSerializer, { "include" => "albums" }) }

          it "returns side-loaded albums" do
            side_loads[:albums].count.should == @tag.albums.count
            side_loads[:meta][:albums][:page].should == 1
            side_loads[:meta][:albums][:count].should == @tag.albums.count
          end
        end
      end
    end
  end
end
