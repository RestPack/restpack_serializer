module RestPack::Serializer::Paging
  extend ActiveSupport::Concern

  module ClassMethods
    def page(params = {})
      options = RestPack::Serializer::Options.new(self.model_class, params)

      page = options.scope_with_filters.paginate(
        page: options.page,
        per_page: options.page_size
      )

      result = {
        self.key => serialize_page(page),
        self.meta_key => serialize_meta(page, options)
      }

      result.merge side_loads(page, options)
    end

    private

    def serialize_page(page)
      page.map { |model| self.new.as_json(model) }
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
      meta
    end
  end
end