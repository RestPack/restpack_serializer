# frozen_string_literal: true

require 'memory_profiler'
require_relative '../lib/restpack_serializer'

class SimpleSerializer
  include RestPack::Serializer
  attributes :id, :title
end

simple_model = {
  id: '123',
  title: 'This is the title'
}

# warmup
SimpleSerializer.as_json(simple_model)

report = MemoryProfiler.report do
  SimpleSerializer.as_json(simple_model)
end

puts '=' * 64
puts 'Simple Serializer:'
puts '=' * 64

report.pretty_print(detailed_report: false)

class ComplexSerializer
  include RestPack::Serializer

  attributes :a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :o, :p, :q, :r, :s, :t
end

complex_model = {
  a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10,
  k: 11, l: 12, m: 13, n: 14, o: 15, p: 16, q: 17, r: 18, s: 19, t: 20
}

# warmup
ComplexSerializer.as_json(complex_model)

report = MemoryProfiler.report do
  ComplexSerializer.as_json(complex_model)
end

puts '=' * 64
puts 'Complex Serializer:'
puts '=' * 64

report.pretty_print(detailed_report: false)
