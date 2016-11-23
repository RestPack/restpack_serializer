require 'spec_helper'

describe RestPack::Serializer do
  before { @original_config = subject.config.clone }
  after { subject.config = @original_config }

  context "#setup" do
    it "has defaults" do
      expect(subject.config.href_prefix).to eq('')
      expect(subject.config.page_size).to eq(10)
    end

    it "can be configured" do
      subject.setup do |config|
        config.href_prefix = '/api/v1'
        config.page_size = 50
      end

      expect(subject.config.href_prefix).to eq('/api/v1')
      expect(subject.config.page_size).to eq(50)
    end
  end
end
