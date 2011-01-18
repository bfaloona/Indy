require "#{File.dirname(__FILE__)}/helper"

describe "Search Performance" do

  context "with a 10000 line log file" do

    large_file = "#{File.dirname(__FILE__)}/large.log"
    before(:all) do
      @indy = Indy.search(large_file).with([/^\[([^\|]+)\|([^\]]+)\] (.*)$/,:severity, :time, :message])
    end

    profile :file => STDOUT, :printer => :flat, :min_percent => 1  do

      it "should profile code using #for(:all)" do
        @indy.for(:all)
      end

      it "should profile code using #for(:field => 'value')" do
        @indy.for(:severity => 'DEBUG')
      end

      it "should profile code using #like(:field => 'value')" do
        @indy.like(:message => 'filesystem')
      end

      it "should profile code using #time()" do
        @indy.after(:time => "12-29-2010 12:11:33").for(:all)
      end

    end

  end

end
