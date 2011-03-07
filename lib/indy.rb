$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'indy/indy'
require 'indy/result_set'
require 'indy/log_formats'
require 'indy/patterns'
require 'indy/source'