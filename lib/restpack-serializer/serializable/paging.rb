module RestPack::Serializer::Paging
  extend ActiveSupport::Concern

  module ClassMethods
    def page(options = {})
      apply_default_options! options
      apply_filters! options

      page = options[:scope].paginate(
        page: options[:page],
        per_page: options[:page_size]
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
        page: options[:page],
        page_size: options[:page_size],
        count: page.total_entries
      }

      meta[:page_count] = (page.total_entries / options[:page_size]) + 1
      meta[:previous_page] = meta[:page] > 1 ? meta[:page] - 1 : nil
      meta[:next_page] = meta[:page] < meta[:page_count] ? meta[:page] + 1 : nil
      meta
    end

    def apply_default_options!(options)
      options.reverse_merge!(
        page: 1,
        page_size: 10,
        includes: [],
        filters: {},
        sort_by: nil,
        sort_direction: :ascending
      )
      options[:scope] ||= default_scope
    end

    def apply_filters!(options)
      if options[:filters].any?
        options[:scope] = options[:scope].where(options[:filters])
      end
    end

    def default_scope
      self.model_class.send(:scoped)
    end
  end
end