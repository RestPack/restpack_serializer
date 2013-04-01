module RestPack
  module Serializable
    module Attributes
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
      end
    end
  end
end