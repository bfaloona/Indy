begin
  require 'simplecov'
  SimpleCov.start if ENV["COVERAGE"]
rescue
  # ignore
end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'indy/source'
require 'indy/indy'
require 'indy/result_set'
require 'indy/log_formats'
