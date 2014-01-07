module RestPack::Serializer
  class Result
    attr_accessor :resources, :meta, :links

    def initialize
      @resources = {}
      @meta = {}
      @links = {}
    end

    def serialize
      result = {}

      unless @resources.empty?
        inject_has_many_links!
        result[@resources.keys.first] = @resources.values.first

        linked = @resources.except(@resources.keys.first)
        result[:linked] = linked unless linked.empty?
      end

      result[:links] = @links unless @links.empty?
      result[:meta] = @meta unless @meta.empty?

      result
    end

    private

    def inject_has_many_links!
      @resources.keys.each do |key|
        @resources[key].each do |item|
          if item[:links]
            item[:links].each do |link_key, link_value|
              unless link_value.is_a? Array
                plural_linked_key = "#{link_key}s".to_sym

                if @resources[plural_linked_key]
                  linked_resource = @resources[plural_linked_key].find { |i| i[:id] == link_value }
                  if linked_resource
                    linked_resource[:links] ||= {}
                    linked_resource[:links][key] ||= []
                    linked_resource[:links][key] << item[:id]
                    linked_resource[:links][key].uniq!
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
