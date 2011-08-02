require 'simplecov'
SimpleCov.start if ENV["COVERAGE"]

require File.expand_path("#{File.dirname(__FILE__)}/../lib/indy") unless 
  $:.include? File.expand_path("#{File.dirname(__FILE__)}/../lib/indy")

# require 'rspec'