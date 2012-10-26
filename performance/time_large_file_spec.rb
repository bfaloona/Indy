require 'rubygems'
require 'indy'

describe '50000 entry file' do
  it 'should find 130 entries using #within time scope' do
    large_file = File.open("#{File.dirname(__FILE__)}/large.log", 'r')

    start_time = Time.now
    indy = Indy.new(
      :source => large_file,
      :log_format => [/^\[([^\|]+)\|([^\]]+)\] (.*)$/,:severity, :time, :message])

    result = indy.within(:time => ["27-12-2010 10:14:25","29-12-2010 12:10:19"]).all
    puts "#{(Time.now - start_time).seconds} \tElapsed seconds to parse 50k line file for all entries in time scope"
    result.size.should == 130
  end
end

