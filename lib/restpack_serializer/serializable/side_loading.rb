module RestPack::Serializer::SideLoading
  extend ActiveSupport::Concern

  module ClassMethods
    def side_loads(models, options)
      { meta: { } }.tap do |side_loads|
        return side_loads if models.empty? || options.include.nil?

        options.include.each do |include|
          side_load_data = side_load(include, models, options)
          side_loads[:meta].merge!(side_load_data[:meta] || {})
          side_loads.merge! side_load_data.except(:meta)
        end
      end
    end

    def can_includes
      @can_includes || []
    end

    def can_include(*includes)
      @can_includes ||= []
      @can_includes += includes
    end

    def links
      {}.tap do |links|
        associations.each do |association|
          if association.macro == :belongs_to
            link_key = "#{self.key}.#{association.name}"
            href = "/#{association.plural_name}/{#{link_key}}"
          elsif association.macro.to_s.match(/has_/)
            singular_key = self.key.to_s.singularize
            link_key = "#{self.key}.#{association.plural_name}"
            href = "/#{association.plural_name}?#{singular_key}_id={#{key}.id}"
          end
          links.merge!(link_key => {
            :href => RestPack::Serializer.config.href_prefix + href,
            :type => association.plural_name.to_sym
            }
          )
        end
      end
    end

    def associations
      can_includes.map do |include|
        association = association_from_include(include)
        association if supported_association?(association.macro)
      end.compact
    end

    private

    def side_load(include, models, options)
      association = association_from_include(include)
      return {} unless supported_association?(association.macro)
      serializer = RestPack::Serializer::Factory.create(association.class_name)
      builder = RestPack::Serializer::SideLoadDataBuilder.new(association,
                                                              models,
                                                              serializer)
      builder.send("side_load_#{association.macro}")
    end

    def supported_association?(association_macro)
      [:belongs_to, :has_many, :has_and_belongs_to_many].include?(association_macro)
    end

    def association_from_include(include)
      raise_invalid_include(include) unless self.can_includes.include?(include)
      possible_relations = [include.to_s.singularize.to_sym, include]
      select_association_from_possibles(possible_relations)
    end

    def select_association_from_possibles(possible_relations)
      possible_relations.each do |relation|
        if association = self.model_class.reflect_on_association(relation)
          return association
        end
      end
      raise_invalid_include(include)
    end

    def raise_invalid_include(include)
      raise RestPack::Serializer::InvalidInclude.new,
        ":#{include} is not a valid include for #{self.model_class}"
    end
  end
end
