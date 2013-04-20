require './spec/spec_helper'

describe RestPack::Serializer::SideLoading do
  context "invalid :includes" do
    before(:each) do
      FactoryGirl.create(:song)
    end

    it "raises an exception" do
      exception = RestPack::Serializer::InvalidInclude
      message = ":wrong is not a valid include for Song"

      expect do
        SongSerializer.side_loads([Song.first], { includes: [:wrong] })
      end.to raise_error(exception, message)
    end
  end
end