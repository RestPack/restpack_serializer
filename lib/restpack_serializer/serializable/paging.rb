module RestPack::Serializer::Paging
  extend ActiveSupport::Concern

  module ClassMethods
    def page(params = {}, scope = nil)
      page_with_options RestPack::Serializer::Options.new(self, params, scope)
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
        Array(RestPack::Serializer::Factory.create(*options.include)).each do |serializer|
          result[:links].merge! serializer.class.links
        end
      end

      side_load_data = side_loads(page, options)
      result[:meta].merge!(side_load_data[:meta] || {})
      result = result.merge side_load_data.except(:meta)
      inject_to_many_links result
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
        include: options.include
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

      url = "#{RestPack::Serializer.config.href_prefix}/#{self.key}.json"

      params = []
      params << "page=#{page}" unless page == 1
      params << "page_size=#{options.page_size}" unless options.default_page_size?
      params << "include=#{options.include.join(',')}" if options.include.any?
      params << options.filters_as_url_params if options.filters.any?

      url += '?' + params.join('&') if params.any?
      url
    end

    def inject_to_many_links(result) #TODO: GJ: extract this into a result class and refactor
      keys = result.keys - [:meta, :links]

      keys.each do |key|
        result[key].each do |item|
          if item[:links]
            item[:links].each do |link_key, link_value|
              unless link_value.is_a? Array
                plural_linked_key = "#{link_key}s".to_sym

                if result[plural_linked_key]
                  linked_resource = result[plural_linked_key].find { |i| i[:id] == link_value }
                  if linked_resource
                    linked_resource[:links] ||= {}
                    linked_resource[:links][key] ||= []
                    linked_resource[:links][key] << item[:id]
                  end
                end
              end
            end
          end
        end
      end

      result
    end
  end
end
