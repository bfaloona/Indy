require "#{File.dirname(__FILE__)}/helper"

describe Indy do

  context "default time handling" do

    before(:all) do
      @indy = Indy.search("2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.")
    end

    it "should parse a standard date" do
      line_hash = {:time => "2000-09-07 14:07:41", :message => "Entering APPLICATION"}
      @indy.parse_date(line_hash).class.should == DateTime
    end

  end

  context "non-default time handling" do

    before(:all) do
      pattern = "(\w+) (\d{4}-\d{2}-\d{2}) (\w+) - (.*)"
      @indy = Indy.new(:source => "INFO 2000-09-07 MyApp - Entering APPLICATION.", :pattern => [pattern, :severity, :time, :application, :message])
    end

    it "should parse a non-standard date" do
      line_hash = {:time => "2000/09/07", :message => "Entering APPLICATION"}
      @indy.parse_date(line_hash).class.should == DateTime
    end

  end

  context "explicit time format" do

    before(:each) do
      pattern = "^([^\s]+) (.*)$"
      @indy = Indy.new(:time_format => '%m-%d-%Y', :source => "1-13-2002 message\n1-14-2002 another message\n1-15-2002 another message", :pattern => [pattern, :time, :message])
    end

    it "should parse a US style date when given a time format" do
      line_hash = {:time => '1-13-2002', :message => 'message'}
      @indy.parse_date(line_hash).class.should == DateTime
    end

    it "should accept standard time format searches even while using an explicit log time format" do
      @indy.after(:time => 'Jan 13 2002').for(:all).count.should == 2
      @indy.after(:time => 'Jan 14 2002').for(:all).last._time.mday.should == 15
    end

  end

  context "built-in _time field" do

    before(:all) do
      log_string = ["2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.",
        "2000-09-07 14:08:41 INFO  MyApp - Exiting APPLICATION.",
        "2000-09-07 14:10:55 INFO  MyApp - Exiting APPLICATION."].join("\n")
      @search_result = Indy.search(log_string).for(:application => 'MyApp')
      @time_search_result = Indy.search(log_string).before(:time => "2100-09-07").for(:application => 'MyApp')
    end

    it "should not exist as an attribute when unless performing a time search" do
      @search_result.first._time.class.should == NilClass
      @time_search_result.first._time.class.should == DateTime
    end

    it "should be accurate" do
      @time_search_result.first._time.to_s.should == "2000-09-07T14:07:41+00:00"
    end

    it "should allow for time range calculations" do
      time_span = @time_search_result.last._time - @time_search_result.first._time
      hours,minutes,seconds,frac = Date.day_fraction_to_time( time_span )
      hours.should == 0
      minutes.should == 3
      seconds.should == 14
    end

  end

end