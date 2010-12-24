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

    context "built in _time field is available" do

      before(:all) do
        log_string = ["2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.",
                      "2000-09-07 14:08:41 INFO  MyApp - Exiting APPLICATION.",
                      "2000-09-07 14:09:00 INFO  MyApp - Entering APPLICATION.",
                      "2000-09-07 14:10:31 WARN  SomeOtherApp - Encountered Error.",
                      "2000-09-08 14:02:02 INFO  MyApp - Exiting APPLICATION."].join("\n")

        @result = Indy.search(log_string).for(:application => 'MyApp')
      end

      it "should be a built-in attribute" do
        @result.first._time.class.should == DateTime
      end
       
    end

  end
end