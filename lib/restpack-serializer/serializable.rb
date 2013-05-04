require 'active_support/concern'
require_relative "options"
require_relative "serializable/attributes"
require_relative "serializable/paging"
require_relative "serializable/side_loading"
require_relative "serializable/filters"

module RestPack
  module Serializer
    extend ActiveSupport::Concern

    include RestPack::Serializer::Paging
    include RestPack::Serializer::Attributes
    include RestPack::Serializer::SideLoading
    include RestPack::Serializer::Filters

    class InvalidInclude < Exception; end

    def as_json(model, options = {})
      @model, @options = model, options

      data = {}
      if self.class.serializable_attributes.present?
        self.class.serializable_attributes.each do |key, name|
          data[key] = self.send(name) if include_attribute?(name)
        end
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
        "#{self.key}_meta".to_sym
      end

    end
  end
end