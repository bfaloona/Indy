require "#{File.dirname(__FILE__)}/helper"

describe Indy do

  context "middle entry search" do

    before(:each) do
      log_string = [
                    "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION.",
                    "2000-09-07 14:08:41 DEBUG MyOtherApp - Exiting APPLICATION.",
                    "2000-09-07 14:09:55 INFO MyApp - Exiting APPLICATION.",
                    "2000-09-07 14:10:41 INFO MyApp - Entering APPLICATION.",
                    "2000-09-07 14:11:41 DEBUG MyOtherApp - Middle Entry",
                    "2000-09-07 14:12:55 INFO MyApp - Exiting APPLICATION.",
                    "2000-09-07 14:13:41 INFO MyApp - Entering APPLICATION.",
                    "2000-09-07 14:14:41 DEBUG MyOtherApp - Exiting APPLICATION.",
                    "2000-09-07 14:15:55 INFO MyApp - Exiting APPLICATION."
                  ].join("\n")
      @indy = Indy.search(log_string)
      puts '.'
    end

    it "should find the middle row" do
      line = @indy.send(:middle_entry)
      #require 'ruby-debug';debugger
      line.message.should == 'Middle Entry'
      #message.should == 'Middle Entry'
    end

  end

end