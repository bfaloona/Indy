begin
  require 'simplecov'
  SimpleCov.start if ENV["COVERAGE"]
rescue
  puts 'Run "gem install simplecov" to enable code coverage reporting'
end

require "#{File.dirname(__FILE__)}/../../../lib/indy"