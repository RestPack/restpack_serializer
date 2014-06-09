module RestPack::Serializer
  class Options
    attr_accessor :page, :page_size, :include, :filters, :serializer,
                  :model_class, :scope, :context, :include_links,
                  :sorting

    def initialize(serializer, params = {}, scope = nil, context = {})
      params.symbolize_keys! if params.respond_to?(:symbolize_keys!)

      @page = 1
      @page_size = RestPack::Serializer.config.page_size
      @include = []
      @filters = filters_from_params(params, serializer)
      @sorting = sorting_from_params(params, serializer)
      @serializer = serializer
      @model_class = serializer.model_class
      @scope = scope || model_class.send(:all)
      @context = context
      @include_links = true

      @page = params[:page].to_i if params[:page]
      @page_size = params[:page_size].to_i if params[:page_size]
      @include = params[:include].split(',').map(&:to_sym) if params[:include]
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

    def default_page_size?
      @page_size == RestPack::Serializer.config.page_size
    end

    def filters_as_url_params
      @filters.sort.map {|k,v| "#{k}=#{v.join(',')}" }.join('&')
    end

    def sorting_as_url_params
      sorting_values = sorting.map { |k, v| v == :asc ? k : "-#{k}" }.join(',')
      "sort=#{sorting_values}"
    end

    private

    def filters_from_params(params, serializer)
      filters = {}
      serializer.filterable_by.each do |filter|
        [filter, "#{filter}s".to_sym].each do |key|
          filters[filter] = params[key].to_s.split(',') if params[key]
        end
      end
      filters
    end

    def sorting_from_params(params, serializer)
      sort_values = params[:sort] && params[:sort].split(',')
      return {} if sort_values.blank? || serializer.serializable_sorting_attributes.blank?
      sorting_parameters = {}

      sort_values.each do |sort_value|
        sort_order = sort_value[0] == '-' ? :desc : :asc
        sort_value = sort_value.gsub(/\A\-/, '').downcase.to_sym
        sorting_parameters[sort_value] = sort_order if serializer.serializable_sorting_attributes.include?(sort_value)
      end
      sorting_parameters
    end
  end
end
