module RestPack::Serializer::SideLoading
  extend ActiveSupport::Concern

  module ClassMethods
    def side_loads(models, options)
      side_loads = {
        :meta => { }
      }
      return side_loads if models.empty? || options.include.nil?

      options.include.each do |include|
        side_load_data = side_load(include, models, options)
        side_loads[:meta].merge!(side_load_data[:meta] || {})
        side_loads.merge! side_load_data.except(:meta)
      end
      side_loads
    end

    def can_includes
      @can_includes || []
    end

    def can_include(*includes)
      @can_includes ||= []
      @can_includes += includes
    end

    def links
      links = {}

      associations.each do |association|
        if association.macro == :belongs_to
          link_key = "#{self.key}.#{association.name}"
          href = "/#{association.plural_name}/{#{link_key}}"
        elsif association.macro == :has_many
          singular_key = self.key.to_s.singularize
          link_key = "#{self.key}.#{association.plural_name}"
          href = "/#{association.plural_name}?#{singular_key}_id={#{key}.id}"
        end

        links[link_key] = {
          :href => RestPack::Serializer.config.href_prefix + href,
          :type => association.plural_name.to_sym
        }
      end

      links
    end

    def associations
      associations = []
      can_includes.each do |include|
        association = association_from_include(include)
        associations << association if supported_association?(association)
      end
      associations
    end

    private

    def side_load(include, models, options)
      association = association_from_include(include)

      if supported_association?(association)
        serializer = RestPack::Serializer::Factory.create(association.class_name)
        return send("side_load_#{association.macro}", association, models, serializer)
      else
        return {}
      end
    end

    def supported_association?(association)
      [:belongs_to, :has_many].include?(association.macro)
    end

    def side_load_belongs_to(association, models, serializer)
      foreign_keys = models.map { |model| model.send(association.foreign_key) }.uniq
      side_load = association.klass.find(foreign_keys)

      return {
        association.plural_name.to_sym => side_load.map { |model| serializer.as_json(model) },
        :meta => { }
      }
    end

    def side_load_has_many(association, models, serializer)
      return {} if models.empty?

      join_table = association.options[:through]

      filters = if join_table
        { join_table => { association.through_reflection.foreign_key.to_sym => models.map(&:id) } }
      else
        { association.foreign_key.to_sym => models.map(&:id) }
      end

      options = RestPack::Serializer::Options.new(serializer.class)
      options.scope = options.scope.joins(join_table) if join_table
      options.filters = filters
      options.include_links = false

      serializer.class.page_with_options(options)
    end

    def association_from_include(include)
      raise_invalid_include(include) unless self.can_includes.include?(include)

      possible_relations = [include.to_s.singularize.to_sym, include]
      possible_relations.each do |relation|
        association = self.model_class.reflect_on_association(relation)
        return association unless association.nil?
      end

      raise_invalid_include(include)
    end

    def raise_invalid_include(include)
      raise RestPack::Serializer::InvalidInclude.new,
        ":#{include} is not a valid include for #{self.model_class}"
    end
  end
end
