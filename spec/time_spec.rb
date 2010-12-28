require "#{File.dirname(__FILE__)}/helper"

module Indy

  describe Indy do

    context "default time handling" do

      before(:all) do
        @indy = Indy.search("2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.")
      end
      
      it "#_time_field should return :time" do
        @indy._time_field.should == :time
      end
      
      it "should parse a standard date" do
        line_hash = {:time => "2000-09-07 14:07:41", :message => "Entering APPLICATION"}
        @indy._parse_date(line_hash).class.should == DateTime
      end

    end

    context "non-default time handling" do

      before(:all) do
        pattern = "(\w+) (\d{4}-\d{2}-\d{2}) (\w+) - (.*)"
        @indy = Indy.new(:source => "INFO 2000-09-07 MyApp - Entering APPLICATION.", :pattern => [pattern, :severity, :date, :application, :message])
      end

      it "#_time_field should return :date" do
        @indy._time_field.should == :date
      end

      it "should parse a non-standard date" do
        line_hash = {:date => "2000/09/07", :message => "Entering APPLICATION"}
        @indy._parse_date(line_hash).class.should == DateTime
      end

    end

    context "built-in _time field" do

      before(:all) do
        log_string = ["2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.",
                      "2000-09-07 14:08:41 INFO  MyApp - Exiting APPLICATION.",
                      "2000-09-07 14:10:55 INFO  MyApp - Exiting APPLICATION."].join("\n")
        @result = Indy.search(log_string).for(:application => 'MyApp')
      end

      it "should be an attribute" do
        @result.first._time.class.should == DateTime
      end

      it "should be accurate" do
        @result.first._time.to_s.should == "2000-09-07T14:07:41+00:00"        
      end

      it "should allow for time range calculations" do
        time_span = @result.last._time - @result.first._time
        hours,minutes,seconds,frac = Date.day_fraction_to_time( time_span )
        hours.should == 0
        minutes.should == 3
        seconds.should == 14
      end
       
    end

    context "time of log entries" do

      before(:all) do
        log_string = ["2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.",
                      "2000-09-07 14:08:40 INFO  MyApp - Exiting APPLICATION.",
                      "2000-09-07 14:09:00 INFO  MyApp - Entering APPLICATION.",
                      "2000-09-07 14:10:31 WARN  SomeOtherApp - Encountered Error.",
                      "2000-09-07 14:10:31 WARN  SomeOtherApp - Encountered Error2.",
                      "2000-09-07 14:10:31 WARN  SomeOtherApp - Encountered Error3.",
                      "2000-09-07 14:10:31 WARN  SomeOtherApp - Encountered Error4.",
                      "2000-09-07 14:10:31 WARN  SomeOtherApp - Encountered Error5.",
                      "2000-09-07 14:10:31 WARN  SomeOtherApp - Encountered Error6.",
                      "2000-09-08 14:02:02 INFO  MyApp - Exiting APPLICATION.",
                      "2000-09-09 14:05:00 INFO  MyApp - Entering APPLICATION.",
                      "2000-09-09 14:06:31 WARN  SomeOtherApp - Encountered Error.",
                      "2000-09-09 14:06:32 WARN  SomeOtherApp - Another Encountered Error.",
                      "2000-09-10 14:07:55 INFO  MyApp - Exiting APPLICATION."].join("\n")
        @log = Indy.search(log_string)
      end

      it "can be used to partition log" do
        @log.last(:half, :time).length.should == 4
      end

      it "can be used filter to a completely relative time range" do
        @log.first("1 minute").length.should == 1
      end

      it "can be used to filter to a partially relative time range" do
        @log.starting("September 8, 2000").at("Noon").for("1 day").length.should == 1
      end
      it "can be used to filter to an absolute time range" do
        @log.starting("September 8, 2000").at("Noon").until("9/9/2000").at("9 pm").length.should == 3
      end

    end

  end
end