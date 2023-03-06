# frozen_string_literal: true

module RestPack
  module Serializer
    class Configuration
      attr_accessor :href_prefix, :page_size

      def initialize
        @href_prefix = ''
        @page_size = 10
      end
    end
  end
end
