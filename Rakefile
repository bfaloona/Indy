require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require "cucumber/rake/task"
require "yard"


desc 'Default: run tests'
task :default => :test

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

desc "Run performance specs"
RSpec::Core::RakeTask.new(:perf) do |t|
  t.pattern = "./performance/**/*_spec.rb"
  t.rspec_opts = ['-f d']
end

desc "Run features"
Cucumber::Rake::Task.new(:features) do |task|
  task.cucumber_opts = ["features", "-f progress"]
end

desc "Run perf, flog, specs and features"
task :all do
  puts "\nProfiling report"
  Rake::Task['perf'].invoke
  puts "\nFlog results"
  Rake::Task['flog'].invoke
  puts "\nSpec Tests"
  Rake::Task['spec'].invoke
  puts "\nCucumber features"
  Rake::Task['features'].invoke
end

desc "Run tests"
task :test do
  Rake::Task['spec'].invoke
  Rake::Task['features'].invoke
end


desc "Flog the code! (*nix only)"
task :flog do
  system('find lib -name \*.rb | xargs flog')
end

desc "Detailed Flog report! (*nix only)"
task :flog_detail do
  system('find lib -name \*.rb | xargs flog -d')
end


# Task :yard -- Generate yard + yard-cucumber docs
YARD::Rake::YardocTask.new do |t|
  t.files   = ['features/**/*', 'lib/**/*.rb']
  t.options = ['--private']
end

puts "\nTo create a report in /coverage, execute:\nCOVERAGE=true rake test\n\n"
