require 'rubygems'
require 'indy'

describe '5000 entry file' do
  it 'should find 130 entries using within' do
    large_file = File.open("#{File.dirname(__FILE__)}/large.log", 'r')

    indy = Indy.new(
      :source => large_file,
      :log_format => [/^\[([^\|]+)\|([^\]]+)\] (.*)$/,:severity, :time, :message])

    result = indy.within(:time => ["27-12-2010 10:14:25","29-12-2010 12:10:19"]).for(:all)
    result.size.should == 130
  end
end

