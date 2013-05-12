class RestPack::Serializer::Factory
  def self.create(*identifiers)
    serializers = identifiers.map { |identifier| self.classify(identifier) }
    serializers.count == 1 ? serializers.first : serializers
  end

  private

  def self.classify(identifier)
    begin
      "#{identifier}Serializer".classify.constantize.new
    rescue
      "#{identifier.to_s.singularize.to_sym}Serializer".classify.constantize.new
    end
  end
end
