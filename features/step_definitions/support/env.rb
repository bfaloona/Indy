require 'simplecov'
SimpleCov.start if ENV["COVERAGE"]
SimpleCov.root("#{File.dirname(__FILE__)}/../../../..")

require "#{File.dirname(__FILE__)}/../../../lib/indy"