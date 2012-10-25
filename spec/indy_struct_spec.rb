require "#{File.dirname(__FILE__)}/helper"

describe 'Indy' do

  context 'Struct::Entry' do

    before(:each) do
      log = [ "2000-09-07 14:06:41 INFO MyApp - Entering APPLICATION.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
      @entry_struct = Indy.search(log).for(:all)[1]
    end

    it "should be returned by #for search" do
      @entry_struct.should be_kind_of Struct::Entry
    end

    it "should contain entire log entry as :entry" do
      @entry_struct.entry.should == "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION."
    end

    context 'using Indy::DEFAULT_LOG_FORMAT' do

      it "should contain :time" do
        @entry_struct.time.should == "2000-09-07 14:07:42"
      end

      it "should contain :severity" do
        @entry_struct.severity.should == "DEBUG"
      end

      it "should contain :application" do
        @entry_struct.application.should == "MyApp"
      end

      it "should contain :message" do
        @entry_struct.message.should == "Initializing APPLICATION."
      end

    end

  end
end
