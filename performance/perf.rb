require 'benchmark'
require_relative '../lib/restpack_serializer'

class SimpleSerializer
  include RestPack::Serializer
  attributes :id, :title
end

iterations = 180_000 #180_000 ~> 1 second
Benchmark.bm(22) do |bm|
  bm.report('simple serializer') do

    model = {
      id: 123,
      title: 'This is the title'
    }

    iterations.times do
      SimpleSerializer.as_json(model)
    end
  end
end
