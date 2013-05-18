module RestPack::Serializer::Resource
  extend ActiveSupport::Concern

  module ClassMethods
    def resource(params = {}, scope = nil)
      #TODO: GJ: create ResourceOptions and PageOptions classes
      page_with_options RestPack::Serializer::Options.new(self.model_class, params, scope)
    end
  end
end
