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
      side_loads = []
      association = association_from_include(include)

      if association.macro == :belongs_to #TODO: GJ: add support for other relations
        foreign_keys = models.map { |model| model.send(association.foreign_key) }.uniq
        side_loads = association.klass.find(foreign_keys)
      end

      serializer = RestPack::Serializer::Factory.create(association.class_name)

      {
        include => side_loads.map { |model| serializer.as_json(model) }
      }
    end

    def association_from_include(include)
      relation = include.to_s.singularize.to_sym
      self.model_class.reflect_on_association(relation)
    end
  end
end