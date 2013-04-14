module RestPack::Serializer::SideLoading
  extend ActiveSupport::Concern

  module ClassMethods
    def side_loads(models, options = {})
      return {} if models.empty? || options[:includes].nil?

      result = {}
      options[:includes].each do |include|
        result[include] = side_load(models, options, include)
      end
      result
    end

    private

    def side_load(models, options, include)
      side_loads = []

      relation = include.to_s.singularize.to_sym
      association = self.model_class.reflect_on_association(relation)

      if association.macro == :belongs_to #TODO: GJ: add support for other relations
        foreign_keys = models.map { |model| model.send(association.foreign_key) }.uniq
        side_loads = association.klass.find(foreign_keys)
      end

      serializer = RestPack::Serializer::Factory.create(association.class_name)

      side_loads.map { |model| serializer.as_json(model) }
    end
  end
end