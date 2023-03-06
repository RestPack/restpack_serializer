require 'active_support/concern'
require_relative 'options'
require_relative 'serializable/attributes'
require_relative 'serializable/filterable'
require_relative 'serializable/paging'
require_relative 'serializable/resource'
require_relative 'serializable/single'
require_relative 'serializable/side_loading'
require_relative 'serializable/side_load_data_builder'
require_relative 'serializable/sortable'

module RestPack
  module Serializer
    extend ActiveSupport::Concern
    mattr_accessor :class_map
    @@class_map ||= {}

    included do
      identifier = to_s.underscore.chomp('_serializer')
      @@class_map[identifier] = self
      @@class_map[identifier.split('/').last] = self
    end

    include RestPack::Serializer::Paging
    include RestPack::Serializer::Resource
    include RestPack::Serializer::Single
    include RestPack::Serializer::Attributes
    include RestPack::Serializer::Filterable
    include RestPack::Serializer::SideLoading
    include RestPack::Serializer::Sortable

    class InvalidInclude < Exception; end

    def as_json(model, context = {})
      return if model.nil?
      return model.map { |item| self.class.new.as_json(item, context) } if model.is_a?(Array)

      apply_whitelist_and_blacklist(context)
      @model = model
      @context = context

      data = {}
      if self.class.serializable_attributes.present?
        self.class.serializable_attributes.each do |key, attribute|
          method_name = attribute[:include_method_name]
          name = attribute[:name]
          if self.class.memoized_has_user_defined_method?(method_name)
            data[key] = send(name) if send(method_name)
          elsif @context[method_name].nil? || @context[method_name]
            # the default implementation of `include_abc?`
            data[key] = send(name)
          end
        end
      end

      add_custom_attributes(data)
      add_links(model, data) if self.class.has_associations?

      data
    end

    def to_json(model, context = {})
      as_json(model, context).to_json
    end

    def custom_attributes
      nil
    end

    private

    def add_custom_attributes(data)
      custom = custom_attributes
      data.merge!(custom) if custom
    end

    def apply_whitelist_and_blacklist(context)
      blacklist = context[:attribute_blacklist]
      whitelist = context[:attribute_whitelist]

      if blacklist.present? && whitelist.present?
        raise ArgumentError, "the context can't define both an `attribute_whitelist` and an `attribute_blacklist`"
      end

      if blacklist.present?
        blacklist = csv_to_symbol_array(blacklist)
        self.class.serializable_attributes.each do |key, value|
          context[value[:include_method_name]] = false if blacklist.include? key
        end
      end

      return unless whitelist.present?

      whitelist = csv_to_symbol_array(whitelist)
      self.class.serializable_attributes.each do |key, value|
        context[value[:include_method_name]] = false unless whitelist.include? key
      end
    end

    def csv_to_symbol_array(maybe_csv)
      if maybe_csv.is_a? String
        maybe_csv.split(',').map { |a| a.strip.to_sym }
      else
        maybe_csv
      end
    end

    def add_links(model, data)
      self.class.associations.each do |association|
        data[:links] ||= {}
        links_value = if association.macro == :belongs_to
                        model.send(association.foreign_key).try(:to_s)
                      elsif association.macro.to_s.match(/has_/)
                        if model.send(association.name).loaded?
                          model.send(association.name).collect { |associated| associated.id.to_s }
                        else
                          model.send(association.name).pluck(:id).map(&:to_s)
                        end
                      end
        data[:links][association.name.to_sym] = links_value unless links_value.blank?
      end
      data
    end

    module ClassMethods
      attr_accessor :model_class, :href_prefix, :key, :user_defined_methods, :track_defined_methods

      def method_added(name)
        # we track used defined methods so that we can make quick decisions at runtime
        @user_defined_methods ||= []
        return unless @track_defined_methods

        @user_defined_methods << name
      end

      def has_user_defined_method?(method_name)
        if user_defined_methods && user_defined_methods.include?(method_name)
          true
        elsif superclass.respond_to?(:has_user_defined_method?)
          superclass.has_user_defined_method?(method_name)
        else
          false
        end
      end

      def memoized_has_user_defined_method?(method_name)
        @memoized_user_defined_methods ||= {}

        return @memoized_user_defined_methods[method_name] if @memoized_user_defined_methods.has_key? method_name

        has_method = has_user_defined_method?(method_name)
        @memoized_user_defined_methods[method_name] = has_method
        has_method
      end

      def array_as_json(models, context = {})
        new.as_json(models, context)
      end

      def as_json(model, context = {})
        new.as_json(model, context)
      end

      def to_json(model, context = {})
        new.as_json(model, context).to_json
      end

      def serialize(models, context = {})
        models = [models] unless models.is_a?(Array)

        {
          key => models.map { |model| as_json(model, context) }
        }
      end

      def model_class
        @model_class || name.chomp('Serializer').constantize
      end

      def href_prefix
        @href_prefix || RestPack::Serializer.config.href_prefix
      end

      def key
        (@key || model_class.send(:table_name)).to_sym
      end

      def singular_key
        key.to_s.singularize.to_sym
      end

      def plural_key
        key
      end
    end
  end
end
