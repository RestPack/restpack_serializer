module RestPack::Serializer::Parameterizable
  extend ActiveSupport::Concern

  module ClassMethods
    def serializable_parameters
      @serializable_parameters || []
    end

    def allow_parameters(*parameters)
      parameters.each do |parameter|
        @serializable_parameters ||= []
        @serializable_parameters << parameter.to_sym
      end
    end
  end
end
