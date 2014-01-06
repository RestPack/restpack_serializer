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

      result[:meta] = @meta unless @meta.empty?
      result[:links] = @links unless @links.empty?

      unless @resources.empty?
        inject_to_many_links!
        result[@resources.keys.first] = @resources.values.first

        linked = @resources.except(@resources.keys.first)
        result[:linked] = linked unless linked.empty?
      end

      result
    end

    private

    def inject_to_many_links! #find and inject to_many links from related @resources
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
