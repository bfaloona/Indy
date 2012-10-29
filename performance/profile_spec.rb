require "#{File.dirname(__FILE__)}/helper"

describe "Search Performance" do

  context "with a 50000 line log file" do

    large_file = File.open("#{File.dirname(__FILE__)}/large.log", 'r')
    before(:all) do
      @indy = Indy.search(large_file).with([/^\[([^\|]+)\|([^\]]+)\] (.*)$/,:severity, :time, :message])
    end

    profile :file => STDOUT, :printer => :flat, :min_percent => 1  do

      it "should profile code using #all" do
        @indy.all
      end

      it "should profile code using #for(:field => 'value')" do
        @indy.for(:severity => 'DEBUG')
      end

      it "should profile code using #like(:field => 'value')" do
        @indy.like(:message => 'filesystem')
      end

      it "should profile code using #after()" do
        @indy.after(:time => "29-12-2010 12:11:32").all
      end

    end

  end

  context "with a 50000 line log file" do

    large_file = File.open("#{File.dirname(__FILE__)}/large.log", 'r')
    before(:all) do
      @indy = Indy.new(
        :source => large_file,
        :log_format => [/^\[([^\|]+)\|([^\]]+)\] (.*)$/,:severity, :time, :message],
        :time_format => '%d-%m-%Y %H:%M:%S')
    end

    profile :file => STDOUT, :printer => :flat, :min_percent => 1  do

      it "should profile code using #after() and an explicit @time_format" do
        @indy.after(:time => "29-12-2010 12:11:32").all
      end

    end

  end

end
