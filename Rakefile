require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require "cucumber/rake/task"

desc 'Default: run tests'
task :default => :tests

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

desc "Run performance specs"
RSpec::Core::RakeTask.new(:perf) do |t|
  t.pattern = "./performance/**/*_spec.rb"
end


desc "Run features"
Cucumber::Rake::Task.new(:features) do |task|
  task.cucumber_opts = ["features", "-f progress"]
end

desc "Run specs and features"
task :tests do
  Rake::Task['perf'].invoke
  Rake::Task['coverage'].invoke
  puts "\nSpec Tests"
  Rake::Task['spec'].invoke
  puts "\nCucumber features"
  Rake::Task['features'].invoke
end

desc "Generate code coverage"
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec', '--exclude', 'gems', '-T']
end