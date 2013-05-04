module RestPack::Serializer::Filters
  extend ActiveSupport::Concern

  module ClassMethods
    def filterable_by
      @filterable_by || []
    end

    def can_filter_by(*filters)
      @filterable_by ||= []
      @filterable_by += filters
      @filterable_by.uniq!
    end
  end
end