require "#{File.dirname(__FILE__)}/helper"

describe 'Indy' do

  context 'Struct::Entry' do

    before(:each) do
      log = [ "2000-09-07 14:06:41 INFO MyApp - Entering APPLICATION.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
      @entry_struct = Indy.search(log).all[1]
    end

    it "should be returned by #for search" do
      expect(@entry_struct).to be_a_kind_of Struct::Entry
    end

    it "should contain entire log entry as :raw_entry" do
      expect(@entry_struct.raw_entry).to eq("2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.")
    end

    context 'using Indy::DEFAULT_LOG_FORMAT' do

      it "should contain :time" do
        expect(@entry_struct.time).to eq("2000-09-07 14:07:42")
      end

      it "should contain :severity" do
        expect(@entry_struct.severity).to eq("DEBUG")
      end

      it "should contain :application" do
        expect(@entry_struct.application).to eq("MyApp")
      end

      it "should contain :message" do
        expect(@entry_struct.message).to eq("Initializing APPLICATION.")
      end

    end

  end
end
