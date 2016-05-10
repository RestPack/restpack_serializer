require 'benchmark'
require_relative '../lib/restpack_serializer'

class SimpleSerializer
  include RestPack::Serializer
  attributes :id, :title
end

class ComplexSerializer
  include RestPack::Serializer

  attributes :a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :o, :p, :q, :r, :s, :t
end

iterations = 180_000

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

  bm.report('complex serializer') do

    model = {
      a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10,
      k: 11, l: 12, m: 13, n: 14, o: 15, p: 16, q: 17, r: 18, s: 19, t: 20,
    }

    iterations.times do
      ComplexSerializer.as_json(model)
    end
  end
end
