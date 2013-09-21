module RestPack::Serializer::Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def serializable_filters
      @serializable_filters
    end

    def can_filter_by(*attributes)
      attributes.each do |attribute|
        @serializable_filters ||= []
        @serializable_filters << attribute.to_sym
      end
    end

    def filterable_by
      filters = [self.model_class.primary_key.to_sym]
      filters += self.model_class.reflect_on_all_associations(:belongs_to).map(&:foreign_key).map(&:to_sym)

      filters += @serializable_filters if @serializable_filters
      filters.uniq
    end
  end
end
