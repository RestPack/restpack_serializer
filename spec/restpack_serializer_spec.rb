require 'spec_helper'

describe RestPack::Serializer do
  before { @original_config = subject.config.clone }
  after { subject.config = @original_config }

  context "#setup" do
    it "has defaults" do
      subject.config.href_prefix.should == ''
      subject.config.page_size.should == 10
    end

    it "can be configured" do
      subject.setup do |config|
        config.href_prefix = '/api/v1'
        config.page_size = 50
      end

      subject.config.href_prefix.should == '/api/v1'
      subject.config.page_size.should == 50
    end
  end
end
