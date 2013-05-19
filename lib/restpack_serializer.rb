require 'will_paginate'
require 'will_paginate/active_record'

require 'restpack_serializer/version'
require 'restpack_serializer/serializable'
require 'restpack_serializer/factory'

module RestPack
  module Serializer
    mattr_accessor :href_prefix

    @@href_prefix = ''
  end
end
