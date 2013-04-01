require_relative 'lib/restpack-serializer/version'

task :default => :test
task :test => :spec

begin
  require "rspec/core/rake_task"

  desc "Run all specs"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ['-cfs']
  end
rescue LoadError
end


task :gem do
  ["gem:build", "gem:push"].each do |task|
    Rake::Task[task].reenable
    Rake::Task[task].invoke
  end
end

namespace :gem do 
  task :build do
    sh "gem build restpack-serializer.gemspec"
  end
  
  task :push do
    sh "gem push restpack-serializer-#{RestPack::Serializer::VERSION}.gem"
  end
end