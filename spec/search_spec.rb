require "#{File.dirname(__FILE__)}/helper"

module Indy

  describe Indy do

    context "search" do

      before(:each) do
        log_string = ["2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.",
                      "2000-09-07 14:08:41 INFO  MyOtherApp - Exiting APPLICATION.",
                      "2000-09-07 14:10:55 INFO  MyApp - Exiting APPLICATION."].join("\n")
        @indy = Indy.search(log_string)
      end

      it "should return 2 records" do
        @indy.for(:application => 'MyApp').length.should == 2
      end

      it "should search entire file on each successive searches" do
        @indy.for(:application => 'MyApp').length.should == 2
        @indy.for(:severity => 'INFO').length.should == 3
        @indy.for(:application => 'MyApp').length.should == 2
      end

    end


  end

end