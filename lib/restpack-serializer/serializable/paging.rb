module RestPack
  module Serializable
    module Paging
      extend ActiveSupport::Concern

      module ClassMethods
        def page(options = {})
          apply_default_options! options

          page = options[:scope].paginate(
            page: options[:page],
            per_page: options[:page_size]
          )

          side_loads = side_load(page, options)

          result = {
            self.key => serialize_page(page),
            self.meta_key => serialize_meta(page, options)
          }

          merge_side_loads(result, options)

          result
        end

        private

        def side_load(page, options)
          []
        end

        def merge_side_loads(result, options)

          options[:includes].each do |include|
            p "TODO: GJ: side-load: #{include}"
            result[include] = []
          end
          
        end

        def serialize_page(page)
          page.map { |model| self.new.as_json(model) }
        end

        def serialize_meta(page, options)
          {
            page: options[:page],
            page_size: options[:page_size],
            count: page.total_entries,
            page_count: (page.total_entries / options[:page_size]) + 1
          }
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
      end
    end
  end
end