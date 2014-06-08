module RestPack::Serializer::Attributes
  extend ActiveSupport::Concern

  def default_href
    "#{RestPack::Serializer.config.href_prefix}/#{self.class.key}/#{@model.to_param}"
  end

  module ClassMethods
    def serializable_attributes
      @serializable_attributes
    end

    def attributes(*attrs)
      attrs.each { |attr| attribute attr }
    end

    def attribute(name, options={})
      options[:key] ||= name.to_sym

      @serializable_attributes ||= {}
      @serializable_attributes[options[:key]] = name

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
