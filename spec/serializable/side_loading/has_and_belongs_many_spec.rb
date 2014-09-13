require 'spec_helper'

describe RestPack::Serializer::SideLoading do
  context "when side-loading" do
    let(:side_loads) { MyApp::ArtistSerializer.side_loads(models, options) }

    describe ".has_and_belongs_to_many" do

      before(:each) do
        @artist1 = FactoryGirl.create(:artist_with_stalkers, stalker_count: 2)
        @artist2 = FactoryGirl.create(:artist_with_stalkers, stalker_count: 3)
      end

      context "with a single model" do
        let(:models) { [@artist1] }

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(MyApp::ArtistSerializer, { "include" => "stalkers" }) }
          let(:stalker_count) { @artist1.stalkers.count }

          it "returns side-loaded albums" do
            side_loads[:stalkers].count.should == stalker_count
            side_loads[:meta][:stalkers][:page].should == 1
            side_loads[:meta][:stalkers][:count].should == stalker_count
          end
        end
      end

      context "with two models" do
        let(:models) { [@artist1, @artist2] }

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(MyApp::ArtistSerializer, { "include" => "stalkers" }) }
          let(:stalker_count) { @artist1.stalkers.count + @artist2.stalkers.count }

          it "returns side-loaded albums" do
            side_loads[:stalkers].count.should == stalker_count
            side_loads[:meta][:stalkers][:count].should == stalker_count
          end
        end
      end
    end
  end
end
