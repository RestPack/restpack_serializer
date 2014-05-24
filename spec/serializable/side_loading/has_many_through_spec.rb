require 'spec_helper'

describe RestPack::Serializer::SideLoading do
  context "when side-loading" do
    describe ".has_many_through" do

      before(:each) do
        @first_tag = FactoryGirl.create(:tag)
        @second_tag = FactoryGirl.create(:tag)
      end
      let(:side_loads) { MyApp::TagSerializer.side_loads(models, options) }

      context "with two models" do
        let(:models) { [@first_tag, @second_tag] }

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(MyApp::TagSerializer, { "include" => "albums" }) }

          it "returns side-loaded albums" do
            side_loads[:albums].count.should == 2
            side_loads[:meta][:albums][:page].should == 1
            side_loads[:meta][:albums][:count].should == 2
          end
        end
      end
    end
  end
end
