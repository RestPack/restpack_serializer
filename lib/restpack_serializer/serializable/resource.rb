module RestPack::Serializer::Resource
  extend ActiveSupport::Concern

  module ClassMethods
    def resource(params = {}, scope = nil)
      page_with_options RestPack::Serializer::Options.new(self, params, scope)
    end
  end
end
