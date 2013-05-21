module RestPack::Serializer::Paging
  extend ActiveSupport::Concern

  module ClassMethods
    def page(params = {}, scope = nil)
      page_with_options RestPack::Serializer::Options.new(self.model_class, params, scope)
    end

    def page_with_options(options)
      page = options.scope_with_filters.paginate(
        page: options.page,
        per_page: options.page_size
      )

      result = {
        self.key => serialize_page(page),
        :meta => {
          self.key => serialize_meta(page, options)
        }
      }

      if options.include_links
        result[:links] = self.links
        Array(RestPack::Serializer::Factory.create(*options.includes)).each do |serializer|
          result[:links].merge! serializer.class.links
        end
      end

      side_load_data = side_loads(page, options)
      result[:meta].merge!(side_load_data[:meta] || {})
      result.merge side_load_data.except(:meta)
    end

    private

    def serialize_page(page)
      page.map { |model| self.as_json(model) }
    end

    def serialize_meta(page, options)
      meta = {
        page: options.page,
        page_size: options.page_size,
        count: page.total_entries,
        includes: options.includes
      }

      meta[:page_count] = ((page.total_entries - 1) / options.page_size) + 1
      meta[:previous_page] = meta[:page] > 1 ? meta[:page] - 1 : nil
      meta[:next_page] = meta[:page] < meta[:page_count] ? meta[:page] + 1 : nil

      meta[:previous_href] = page_href(meta[:previous_page], options)
      meta[:next_href] = page_href(meta[:next_page], options)
      meta
    end

    def page_href(page, options)
      return nil unless page

      url = "#{RestPack::Serializer.href_prefix}/#{self.key}.json"

      params = []
      params << "page=#{page}" unless page == 1
      params << "page_size=#{options.page_size}" unless options.default_page_size?
      params << "includes=#{options.includes.join(',')}" if options.includes.any?
      params << options.filters_as_url_params if options.filters.any?

      url += '?' + params.join('&') if params.any?
      url
    end
  end
end
