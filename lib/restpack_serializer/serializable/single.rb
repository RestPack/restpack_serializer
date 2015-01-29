module RestPack::Serializer::Single
  extend ActiveSupport::Concern

  module ClassMethods
    def single(params = {}, scope = nil, context = {})
      options = RestPack::Serializer::Options.new(self, params, scope, context)
      model = options.scope_with_filters.first

      return model ? self.as_serialized(model, context) : nil
    end
  end
end
