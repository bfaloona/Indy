require "#{File.dirname(__FILE__)}/helper"

class Indy

  describe Source do

    context "#new" do

      it "should raise without parameter" do
        expect{ Source.new }.to raise_error( ArgumentError )
      end

      it "should raise with nil parameter" do
        expect{ Source.new(nil) }.to raise_error( Indy::Source::Invalid )
      end

      it "should raise with bad parameter" do
        class NotString;end
        expect{ Source.new(NotString.new) }.to raise_error( Indy::Source::Invalid )
      end

      it "should raise if #execute_command returns empty string" do
        allow(IO).to receive(:popen).and_return('')
        expect{ Source.new(:cmd => 'a faux command').open }.to raise_error(Indy::Source::Invalid)
      end

      it "should return Indy::Source object" do
        expect(Source.new('logdata').class).to eq(Indy::Source)
      end

      it "should respond to :open" do
        expect(Source.new('logdata')).to respond_to(:open)
      end

      it "should respond to :num_entries" do
        expect(Source.new('logdata')).to respond_to(:num_entries)
      end

      it "should respond to :entries" do
        expect(Source.new('logdata')).to respond_to(:entries)
      end

      it "should handle Files" do
        require 'tempfile'
        expect(Source.new(Tempfile.new('x')).class).to eq(Indy::Source)
      end

    end

    context "instance" do

      before(:each) do
        log = [ "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION.",
                "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
                "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."
              ].join("\n")
        @source = Source.new(log)
      end

      it "should return StringIO from :open" do
        expect(@source.open.class).to eq(Array)
      end

      it "should return entries array from :entries" do
        expect(@source.entries.class).to eq(Array)
        expect(@source.entries.length).to eq(3)
      end

      it "should return 3 from :num_entries" do
        expect(@source.num_entries).to eq(3)
      end

    end

    it "should handle a :file hash key with File object value" do
      require 'tempfile'
      file = Tempfile.new('x')
      expect(Source.new(:file => file).class).to eq(Indy::Source)
    end

    it "should handle a bare File object" do
      require 'tempfile'
      file = Tempfile.new('y')
      expect(Source.new(file).class).to eq(Indy::Source)
    end

    it "should handle a real file" do
      log_file = "#{File.dirname(__FILE__)}/data.log"
      expect(Indy.search(:file => File.open(log_file, 'r')).for(:application => 'MyApp').length).to eq(2)
    end

  end
end
