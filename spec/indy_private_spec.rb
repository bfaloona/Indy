require "#{File.dirname(__FILE__)}/helper"

describe 'Indy' do

  context 'instance private method' do

    before(:all) do
      log = [ "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
      @indy = Indy.search(log)
    end

    it "#last_entries should return an array of Struct::Line object" do
      @indy.send(:last_entries, 2).class.should == Array
      @indy.send(:last_entries, 2).first.class.should == Struct::Line
    end

    it "#last_entries should return correct Struct::Line objects" do
      @indy.send(:last_entries, 2).first.time.should == '2000-09-07 14:07:43'
    end

    it "#parse_line should return a hash" do
      @indy.send(:parse_line, "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION.").class.should == Hash
    end

    it "#parse_line hash should have fields as key/value pairs" do
      hash = @indy.send(:parse_line, "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION.")
      hash[:time] == "2000-09-07 14:07:41"
      hash[:message] == "Entering APPLICATION."
    end

  end
end
