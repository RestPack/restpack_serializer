require_relative "serializable/attributes"
require_relative "serializable/paging"

module RestPack
  module Serializable    
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(RestPack::Serializable::Attributes)
      base.extend(RestPack::Serializable::Paging)
      super
    end

    def as_json(model, options = {})
      @model, @options = model, options

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
      def model_name
        self.name.chomp('Serializer')
      end

      def model_class
        model_name.constantize
      end

      def key
        self.model_class.send(:table_name).to_sym
      end

      def meta_key
        "#{self.model_class.send(:table_name)}_meta".to_sym
      end

      def default_scope
        self.model_class.send(:scoped)
      end
    end
  end
end