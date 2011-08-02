require 'simplecov'
SimpleCov.start if ENV["COVERAGE"]
SimpleCov.root("#{File.dirname(__FILE__)}/../..")

require File.expand_path("#{File.dirname(__FILE__)}/../lib/indy") unless 
  $:.include? File.expand_path("#{File.dirname(__FILE__)}/../lib/indy")

# require 'rspec'