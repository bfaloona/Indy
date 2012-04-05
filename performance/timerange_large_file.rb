require 'rubygems'
require 'indy'
large_file = File.open("#{File.dirname(__FILE__)}/large.log", 'r')

indy = Indy.new(
    :source => large_file,
    :log_format => [/^\[([^\|]+)\|([^\]]+)\] (.*)$/,:severity, :time, :message])
#    :time_format => '%d-%m-%Y %H:%M:%S')

result = indy.within(:time => ["29-12-2010 12:11:32","27-12-2010 10:12:13"]).for(:all)
puts result.class
puts result.size
