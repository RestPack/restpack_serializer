class RestPack::Serializer::Factory
  def self.create(*identifiers)
    serializers = identifiers.map { |identifier| self.classify(identifier) }
    serializers.count == 1 ? serializers.first : serializers
  end

  private

  def self.classify(identifier)
    normalised_identifier = identifier.to_s.underscore
    [normalised_identifier, normalised_identifier.singularize].each do |format|
      klass = RestPack::Serializer.class_map[format]
      return klass.new if klass
    end

    raise "Invalid RestPack::Serializer : #{identifier}"
  end
end
