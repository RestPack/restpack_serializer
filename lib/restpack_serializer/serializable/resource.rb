# frozen_string_literal: true

module RestPack
  module Serializer
    module Resource
      extend ActiveSupport::Concern

      module ClassMethods
        def resource(params = {}, scope = nil, context = {})
          page_with_options RestPack::Serializer::Options.new(self, params, scope, context)
        end
      end
    end
  end
end
