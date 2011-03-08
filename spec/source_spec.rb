require "#{File.dirname(__FILE__)}/helper"

class Indy

  describe Source do

    it "should raise without parameter" do
      lambda{ Source.new }.should raise_error( ArgumentError )
    end

    it "should create Indy::Source object" do
      Source.new('logdata').class.should == Indy::Source
    end

    it "should respond to :open" do
      Source.new('logdata').should respond_to(:open)
    end

    it "should respond to :num_lines" do
      Source.new('logdata').should respond_to(:num_lines)
    end

    it "should respond to :lines" do
      Source.new('logdata').should respond_to(:num_lines)
    end

    context "instance" do
      
      before(:each) do
        log = [ "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION.",
                "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
                "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
        @source = Source.new(log)
      end
      
      it "should return StringIO from :open" do
        @source.open.class.should == StringIO
      end

      it "should return lines array from :lines" do
        @source.lines.class.should == Array
        @source.lines.length.should == 3
      end

      it "should return 3 from :num_lines" do
        @source.num_lines.should == 3
      end

    end
  end

end