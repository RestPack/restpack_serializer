module RestPack::Serializer::Attributes
  extend ActiveSupport::Concern

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
          @model.send(name)
        end
      end
    end

    def define_include_method(name)
      method = "include_#{name}?".to_sym

      unless method_defined?(method)
        define_method method do
          @options[method].nil? || @options[method]
        end
      end
    end
  end
end