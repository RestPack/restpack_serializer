class RestPack::Serializer::Factory
  def self.create(model_class)
    "#{model_class}Serializer".classify.constantize.new
  end
end