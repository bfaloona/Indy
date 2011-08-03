begin
  require 'simplecov'
  SimpleCov.start if ENV["COVERAGE"]
rescue Exception => e
  puts 'Run "gem install simplecov" to enable code coverage reporting'
end

require File.expand_path("#{File.dirname(__FILE__)}/../lib/indy") unless 
  $:.include? File.expand_path("#{File.dirname(__FILE__)}/../lib/indy")

# require 'rspec'