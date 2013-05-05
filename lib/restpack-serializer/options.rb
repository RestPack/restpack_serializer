module RestPack::Serializer
  class Options
    attr_accessor :page, :page_size, :includes, :filters, :model_class, :scope

    def initialize(model_class, params = {})
      params.symbolize_keys! if params.respond_to?(:symbolize_keys!)

      @page = 1
      @page_size = 10
      @includes = []
      @filters = filters_from_params(params, model_class)
      @model_class = model_class
      @scope = model_class.send(:scoped)

      @page = params[:page].to_i if params[:page]
      @page_size = params[:page_size].to_i if params[:page_size]
      @includes = params[:includes].split(',').map(&:to_sym) if params[:includes]
    end

    def scope_with_filters
      scope_filter = {}
      @filters.keys.each do |filter|
        value = @filters[filter]
        if value.is_a?(String)
          value = value.split(',')
        end
        scope_filter[filter] = value
      end

      @scope.where(scope_filter)
    end

    private

    def filters_from_params(params, model_class)
      serializer = RestPack::Serializer::Factory.create(model_class)
      filters = {}
      serializer.class.filterable_by.each do |filter|
        [filter, "#{filter}s".to_sym].each do |key|
          filters[filter] = params[key].split(',') if params[key]
        end
      end
      filters
    end

  end
end
