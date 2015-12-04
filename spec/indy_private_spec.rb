require "#{File.dirname(__FILE__)}/helper"

describe 'Indy' do

  context 'instance private method' do

    before(:all) do
      log = [ "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
      @indy = Indy.search(log)
    end

    it "#last_entries should return an array of Struct::Entry object" do
      expect(@indy.send(:last_entries, 2).class).to eq(Array)
      expect(@indy.send(:last_entries, 2).first.class).to eq(Struct::Entry)
    end

    it "#last_entries should return correct Struct::Entry objects" do
      expect(@indy.send(:last_entries, 2).first.time).to eq('2000-09-07 14:07:43')
    end

  end
end
