module RestPack::Serializer::Attributes
  extend ActiveSupport::Concern

  def default_href
    "#{self.class.href_prefix}/#{self.class.key}/#{@model.to_param}"
  end

  module ClassMethods
    def serializable_attributes
      @serializable_attributes
    end

     def serializable_attributes_options
      @serializable_attributes_options
    end

    def attributes(*attrs)
      attrs.each { |attr| attribute attr }
    end

    def attribute(name, options={})
      key = options[:key] || name.to_sym
      options.delete :key

      @serializable_attributes ||= {}
      @serializable_attributes[key] = name

      @serializable_attributes_options ||= {}
      @serializable_attributes_options[key] = options

      define_attribute_method name
      define_include_method name
    end

    def define_attribute_method(name)
      unless method_defined?(name)
        define_method name do
          value = self.default_href if name == :href
          value ||= @model.send(name)
          value = value.to_s if name == :id
          value
        end
      end
    end

    def define_include_method(name)
      method = "include_#{name}?".to_sym

      unless method_defined?(method)
        define_method method do
          @context[method].nil? || @context[method]
        end
      end
    end
  end
end
