class Symbolizer
  def self.recursive_symbolize(hash)
    {}.tap do |h|
      hash.each { |key, value| h[key.to_sym] = self.map_value(value) }
    end
  end

  private

  def self.map_value(thing)
    case thing
    when Hash
      self.recursive_symbolize(thing)
    when Array
      thing.map { |v| map_value(v) }
    else
      thing
    end
  end
end
