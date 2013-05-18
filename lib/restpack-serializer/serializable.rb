require 'active_support/concern'
require_relative "options"
require_relative "serializable/attributes"
require_relative "serializable/paging"
require_relative "serializable/resource"
require_relative "serializable/side_loading"

module RestPack
  module Serializer
    extend ActiveSupport::Concern

    include RestPack::Serializer::Paging
    include RestPack::Serializer::Resource
    include RestPack::Serializer::Attributes
    include RestPack::Serializer::SideLoading

    class InvalidInclude < Exception; end

    def as_json(model, options = {})
      @model, @options = model, options

      data = {}
      if self.class.serializable_attributes.present?
        self.class.serializable_attributes.each do |key, name|
          data[key] = self.send(name) if include_attribute?(name)
        end
      end

      add_links(model, data)

      data
    end

    private

    def add_links(model, data)
      self.class.associations.each do |association|
        if association.macro == :belongs_to
          data[:links] ||= {}
          data[:links][association.name.to_sym] = model.send(association.foreign_key).to_s
        end
      end
      data
    end

    def include_attribute?(name)
      self.send("include_#{name}?".to_sym)
    end

    module ClassMethods
      def as_json(model, options = {})
        new.as_json(model, options)
      end

      def model_name
        self.name.chomp('Serializer')
      end

      def model_class
        model_name.constantize
      end

      def key
        self.model_class.send(:table_name).to_sym
      end

    end
  end
end
