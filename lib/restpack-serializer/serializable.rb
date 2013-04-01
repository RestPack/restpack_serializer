require_relative "serializable/attributes"

module RestPack
  module Serializable    
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(RestPack::Serializable::Attributes)
      super
    end

    def as_json(model, options = {})
      @model = model
      @options = options

      data = {}
      self.class.serializable_attributes.each do |key, name|
        data[key] = self.send(name) if include_attribute?(name)
      end
      data
    end

    def include_attribute?(name)
      self.send("include_#{name}?".to_sym)
    end

    module ClassMethods

    end
  end
end