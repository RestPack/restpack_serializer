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
      @can_include_options = {}
      @can_include_options = includes.last if includes.last.is_a?(Hash)
      @can_includes ||= []
      @can_includes += includes.flat_map do
        |include| include.try(:keys)|| include
      end
    end

    def links
      {}.tap do |links|
        non_polymorphic_associations.each do |association|
          link_key = if association.macro == :belongs_to
            "#{key}.#{association.name}"
          elsif association.macro.to_s.match(/has_/)
            "#{key}.#{association.plural_name}"
          end

          links.merge!(link_key => {
            :href => href_prefix + url_for_association(association),
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

    def non_polymorphic_associations
      associations.select do |association|
        !association.polymorphic?
      end
    end

    def side_load(include, models, options)
      association = association_from_include(include)
      return {} unless supported_association?(association.macro)
      builder = RestPack::Serializer::SideLoadDataBuilder.new(association,models)
      builder.send("side_load_#{association.macro}")
    end

    def supported_association?(association_macro)
      [:belongs_to, :has_many, :has_and_belongs_to_many].include?(association_macro)
    end

    def association_from_include(include)
      raise_invalid_include(include) unless can_include?(include)
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

    def can_include?(include)
      !!self.can_includes.index do |can_include|
        can_include == include || can_include.to_s == include
      end
    end

    def raise_invalid_include(include)
      raise RestPack::Serializer::InvalidInclude.new,
        ":#{include} is not a valid include for #{self.model_class}"
    end

    def url_from_association(association)
      serializer_from_association_class(association).url
    end

    def url_for_association(association)
      identifier = if association.macro == :belongs_to
        "/{#{key}.#{association.name}}"
      else association.macro.to_s.match(/has_/)
        param = can_include_options(association)[:param] || "#{singular_key}_id"
        value = can_include_options(association)[:value] || "id"

        "?#{param}={#{key}.#{value}}"
      end

      "/#{url_from_association(association)}#{identifier}"
    end

    def can_include_options(association)
      @can_include_options.fetch(association.name.to_sym, {})
    end

    def serializer_from_association_class(association)
      RestPack::Serializer::Factory.create(association.class_name)
    end
  end
end
