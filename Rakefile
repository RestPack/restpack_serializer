# frozen_string_literal: true

require 'restpack_gem'
RestPack::Gem::Tasks.load_tasks

desc 'Run some performance tests'
task :perf do
  require_relative 'performance/perf'
  require_relative 'performance/mem'
end
