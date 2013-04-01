require_relative "serializable/attributes"

module RestPack
  module Serializable    
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(RestPack::Serializable::Attributes)
      super
    end

    def as_json(model)
      @model = model

      data = {}
      self.class.serializable_attributes.each do |key, model_attribute|
        data[key] = self.send(model_attribute)
      end
      data
    end

    module ClassMethods

    end
  end
end