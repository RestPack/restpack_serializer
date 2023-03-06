# frozen_string_literal: true

module RestPack
  module Serializer
    module Single
      extend ActiveSupport::Concern

      module ClassMethods
        def single(params = {}, scope = nil, context = {})
          options = RestPack::Serializer::Options.new(self, params, scope, context)
          model = options.scope_with_filters.first

          model ? as_json(model, context) : nil
        end
      end
    end
  end
end
