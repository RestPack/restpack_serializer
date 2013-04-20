module RestPack::Serializer::SideLoading
  extend ActiveSupport::Concern

  module ClassMethods
    def side_loads(models, options = {})
      side_loads = {}
      return side_loads if models.empty? || options[:includes].nil?

      options[:includes].each do |include|
        side_loads.merge! side_load(include, models, options)
      end
      side_loads
    end

    private

    def side_load(include, models, options)
      side_load = []
      association = association_from_include(include)
      serializer = RestPack::Serializer::Factory.create(association.class_name)

      if association.macro == :belongs_to #TODO: GJ: add support for other relations
        foreign_keys = models.map { |model| model.send(association.foreign_key) }.uniq
        side_load = association.klass.find(foreign_keys)

        return {
          include => side_load.map { |model| serializer.as_json(model) }
        }
      elsif association.macro == :has_many
        raise "We do not yet support side-loading :has_many relationships"
      end

      return {}
    end

    def association_from_include(include)
      relation = include.to_s.singularize.to_sym
      association = self.model_class.reflect_on_association(relation)

      if association.nil?
        message = ":#{include} is not a valid include for #{self.model_class}"
        raise RestPack::Serializer::InvalidInclude.new, message
      end

      association
    end
  end
end