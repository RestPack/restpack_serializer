module RestPack
  module Serializable
    module Paging
      def page(options = {})
        apply_default_options! options

        page = options[:scope].paginate(
          page: options[:page],
          per_page: options[:page_size]
        )

        result = {}
        result[self.key] = page.map { |model| self.new.as_json(model) }

        result[self.meta_key] = {
          page: options[:page],
          page_size: options[:page_size],
          count: page.total_entries,
          page_count: (page.total_entries / options[:page_size]) + 1
        }

        result
      end

      private

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
    end
  end
end