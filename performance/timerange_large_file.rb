require 'rubygems'
require 'indy'
large_file = File.open("#{File.dirname(__FILE__)}/large.log", 'r')

indy = Indy.new(
    :source => large_file,
    :log_format => [/^\[([^\|]+)\|([^\]]+)\] (.*)$/,:severity, :time, :message],
    :time_format => '%d-%m-%Y %H:%M:%S')

indy.after(:time => "29-12-2010 12:11:32").for(:all){ |line|
#  puts line.message
print '.'
}
puts
