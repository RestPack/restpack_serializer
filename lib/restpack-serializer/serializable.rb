require_relative "serializable/attributes"
require_relative "serializable/serialization"

module RestPack
  module Serializable    
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(RestPack::Serializable::Attributes)
      base.extend(RestPack::Serializable::Serialization)
      super
    end

    module ClassMethods

    end
  end
end