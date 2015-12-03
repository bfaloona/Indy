require "#{File.dirname(__FILE__)}/helper"

class Indy

  describe Source do

    context "#new" do

      it "should raise without parameter" do
        lambda{ Source.new }.should raise_error( ArgumentError )
      end

      it "should raise with nil parameter" do
        lambda{ Source.new(nil) }.should raise_error( Indy::Source::Invalid )
      end

      it "should raise with bad parameter" do
        class NotString;end
        lambda{ Source.new(NotString.new) }.should raise_error( Indy::Source::Invalid )
      end

      it "should raise if #execute_command returns empty string" do
        IO.stub(:popen).and_return('')
        lambda{ Source.new(:cmd => 'a faux command').open }.should raise_error(Indy::Source::Invalid)
      end

      it "should return Indy::Source object" do
        Source.new('logdata').class.should == Indy::Source
      end

      it "should respond to :open" do
        Source.new('logdata').should respond_to(:open)
      end

      it "should respond to :num_entries" do
        Source.new('logdata').should respond_to(:num_entries)
      end

      it "should respond to :entries" do
        Source.new('logdata').should respond_to(:entries)
      end

      it "should handle Files" do
        require 'tempfile'
        Source.new(Tempfile.new('x')).class.should == Indy::Source
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
        @source.open.class.should == Array
      end

      it "should return entries array from :entries" do
        @source.entries.class.should == Array
        @source.entries.length.should == 3
      end

      it "should return 3 from :num_entries" do
        @source.num_entries.should == 3
      end

    end

    it "should handle a :file hash key with File object value" do
      require 'tempfile'
      file = Tempfile.new('x')
      Source.new(:file => file).class.should == Indy::Source
    end

    it "should handle a bare File object" do
      require 'tempfile'
      file = Tempfile.new('y')
      Source.new(file).class.should == Indy::Source
    end

    it "should handle a real file" do
      log_file = "#{File.dirname(__FILE__)}/data.log"
      Indy.search(:file => File.open(log_file, 'r')).for(:application => 'MyApp').length.should == 2
    end

  end
end
