module RestPack::Serializer
  class Options
    attr_accessor :page, :page_size, :include, :filters, :serializer,
                  :model_class, :scope, :context, :include_links,
                  :through

    def initialize(serializer, params = {}, scope = nil, context = {})
      params.symbolize_keys! if params.respond_to?(:symbolize_keys!)

      @page = 1
      @page_size = RestPack::Serializer.config.page_size
      @include = []
      @filters = filters_from_params(params, serializer)
      @through = {}
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
      if @through.any?
        join_table_name = @through[:join_table]
        foreign_key = @through[:source_key]
        foreign_values = @through[:source_ids].join(',')

        # TODO potential injection ?
        # TODO handle @filters
        @scope.joins("INNER JOIN #{join_table_name} ON #{join_table_name}.#{foreign_key} IN (#{foreign_values})")
      else
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
    end

    def default_page_size?
      @page_size == RestPack::Serializer.config.page_size
    end

    def filters_as_url_params
      @filters.sort.map {|k,v| "#{k}=#{v.join(',')}" }.join('&')
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
  end
end
