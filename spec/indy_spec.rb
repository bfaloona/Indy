require "#{File.dirname(__FILE__)}/helper"

describe Indy do

  context :initialize do

    # http://log4r.rubyforge.org/rdoc/Log4r/rdoc/patternformatter.html
    it "should accept a log4r pattern string without error" do
      lambda { Indy.new(:pattern => ["(%d) (%i) (%c) - (%m)", :time, :info, :class, :message]) }.should_not raise_error
    end

    # http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PatternLayout.html
    it "should accept a log4j pattern string without error" do
      lambda { Indy.new(:pattern => ["%d [%M] %p %C{1} - %m", :time, :info, :class, :message])}
    end

    it "should not raise error with non-conforming data" do
      @indy = Indy.new(:source => " \nfoobar\n\n baz", :pattern => ['([^\s]+) (\w+)', :time, :message])
      lambda{ @indy.for(:all) }.should_not raise_error
    end

    it "should accept time_format parameter" do
      @indy = Indy.new(:time_format => '%d-%m-%Y', :source => "1-13-2000 yes", :pattern => ['^([^\s]+) (\w+)$', :time, :message])
      lambda{ @indy.for(:all) }.should_not raise_error
      @indy.instance_variable_get(:@time_format).should == '%d-%m-%Y'
    end

    it "should accept an initialization hash passed to #search" do
      hash = {:time_format => '%d-%m-%Y',
        :source => "1-13-2000 yes",
        :pattern => ['^([^\s]+) (\w+)$', :time, :message]}
      lambda{ @indy = Indy.search( hash ) }.should_not raise_error
      @indy.for(:all).count.should == 1
    end


  end

  context 'instance' do

    before(:all) do
      @indy = Indy.new(:source => '1/2/2002 string', :pattern => ['([^\s]+) (\w+)', :time, :message])
    end

    context "method" do

      it "parse_line() should return a hash" do
        @indy.send(:parse_line, "1/2/2002 string").class.should == Hash
      end

      it "parse_line() should return :time and :message" do
        hash = @indy.send(:parse_line, "1/2/2002 string")
        hash[:time] == "1/2/2002"
        hash[:message] == "string"
      end

    end

  end

  context :search do

    it "should be a class method" do
      Indy.should respond_to(:search)
    end

    it "should accept a string parameter" do
      lambda{ Indy.search("String Log") }.should_not raise_error
    end

    it "should accept a :cmd symbol and a command string parameter" do
      lambda{ Indy.search(:cmd =>"ls") }.should_not raise_error
    end

    it "should return an instance of Indy" do
      Indy.search("source string").should be_kind_of(Indy)
      Indy.search(:cmd => "ls").should be_kind_of(Indy)
    end

    it "the instance should have the source specified" do
      Indy.search("source string").source.should_not be_nil
      Indy.search(:cmd => "ls").source.should_not be_nil
    end

    context "for a String" do

      let(:log_file) { "#{File.dirname(__FILE__)}/data.log" }

      context "treat it first like a file" do

        it "should attempt to open the file" do
          File.should_receive(:exist?).with("possible_file.ext").ordered
          Indy.search("possible_file.ext")
        end

        it "should not throw an error for a non-existent file" do
          lambda { Indy.search("possible_file.ext") }.should_not raise_error
        end

        it "should return an IO object when there is a file" do
          File.should_receive(:exist?).with("file_exists.ext").and_return( true )
          File.should_receive(:open).and_return(StringIO.new("2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION."))
          Indy.search("file_exists.ext").for(:application => 'MyApp').length.should == 1
        end

        it "should handle a real file" do
          Indy.search(log_file).for(:application => 'MyApp').length.should == 2
        end

      end

      context "treat it second like a string" do

        it "should attempt to treat it as a string" do
          string = "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION."
          string_io = StringIO.new(string)
          StringIO.should_receive(:new).with(string).ordered.and_return(string_io)
          Indy.search(string).for(:application => 'MyApp').length.should == 1
        end

      end


      context "treat it optionally like a command" do

        it "should attempt open the command" do
          IO.stub!(:popen).with('ssh user@system "bash --login -c \"cat /var/log/standard.log\" "')
          Indy.search(:cmd => 'ssh user@system "bash --login -c \"cat /var/log/standard.log\" "')
        end

        it "should not throw an error for an invalid command" do
          IO.stub!(:popen).with('an invalid command').and_return('')
          lambda { Indy.search(:cmd => "an invalid command") }.should_not raise_error
        end

        it "should return an IO object upon a successful command" do
          IO.stub!(:popen).with("a command").and_return(StringIO.new("2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION."))
          Indy.search(:cmd => "a command").for(:application => 'MyApp').length.should == 1
        end

        it "should handle a real command" do
          Indy.search(:cmd => "cat #{log_file}").for(:application => 'MyApp').length.should == 2
        end

      end

    end

  end

  context "instance" do

    before(:each) do
      log = "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n \n2000-09-07 14:07:41 INFO  MyApp  Entering APPLICATION.\n2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n\n"
      @indy = Indy.search(log)
    end

    it "with() should be a method" do
      @indy.should respond_to(:with)
    end

    # http://log4r.rubyforge.org/rdoc/Log4r/rdoc/patternformatter.html
    it "with() should accept a log4r pattern string without error" do
      lambda { @indy.with(["(%d) (%i) (%c) - (%m)", :time, :info, :class, :message]) }.should_not raise_error
    end

    # http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PatternLayout.html
    it "with() should accept a log4j pattern string without error" do
      lambda { @indy.with(["(%d) (%i) (%c) - (%m)", :time, :info, :class, :message])}.should_not raise_error
    end

    it "should return itself" do
      @indy.with(["(%d) (%i) (%c) - (%m)", :time, :info, :class, :message]).should == @indy
    end

    [:for, :like, :matching].each do |method|
      it "#{method}() should exist" do
        @indy.should respond_to(method)
      end

      it "#{method}() should accept a hash of search criteria" do
        lambda { @indy.send(method,:severity => "INFO") }.should_not raise_error
      end

      it "#{method}() should return a set of results" do
        @indy.send(method,:severity => "DEBUG").should be_kind_of(Array)
      end

    end

    context "_search" do

      before(:each) do
        @results = @indy.send(:_search) {|result| result if result[:application] == "MyApp" }
      end

      it "should not return nil" do
        @results.should_not be_nil
        @results.should be_kind_of(Array)
        @results.should_not be_empty
      end

      it "should return an array of results" do
        @results.first[:application].should == "MyApp"
      end

    end

  end
end
