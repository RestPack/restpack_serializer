module RestPack
  module Serializer
    class SideLoadDataBuilder

      def initialize(association, models, serializer)
        @association = association
        @models = models
        @serializer = serializer
      end

      def side_load_belongs_to
        foreign_keys = @models.map { |model| model.send(@association.foreign_key) }.uniq
        side_load = @association.klass.find(foreign_keys)
        json_model_data = side_load.map { |model| @serializer.as_json(model) }
        { @association.plural_name.to_sym => json_model_data, meta: { } }
      end

      def side_load_has_many
        has_association_relation do |options|
          if join_table = @association.options[:through]
            options.scope = options.scope.joins(join_table)
            association_fk = @association.through_reflection.foreign_key.to_sym
            options.filters = { join_table => { association_fk => model_ids } }
          else
            options.filters = { @association.foreign_key.to_sym => model_ids }
          end
        end
      end

      def side_load_has_and_belongs_to_many
        has_association_relation do |options|
          join_table_name = @association.join_table
          join_clause = "join #{join_table_name} on #{@association.plural_name}.id = #{join_table_name}.#{@association.class_name.foreign_key}"
          options.scope = options.scope.joins(join_clause)
          association_fk = @association.foreign_key.to_sym
          options.filters = { join_table_name.to_sym => { association_fk => model_ids } }
        end
      end

      private

      def model_ids
        @models.map(&:id)
      end

      def has_association_relation
        return {} if @models.empty?
        serializer_class = @serializer.class
        options = RestPack::Serializer::Options.new(serializer_class)
        yield options
        options.include_links = false
        serializer_class.page_with_options(options)
      end
    end
  end
end
