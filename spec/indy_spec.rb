require "#{File.dirname(__FILE__)}/helper"

describe 'Indy' do

  context ':initialize' do

    # http://log4r.rubyforge.org/rdoc/Log4r/rdoc/patternformatter.html
    it "should accept a log4r pattern string without error" do
      Indy.new(:log_format => ["(%d) (%i) (%c) - (%m)", :time, :info, :class, :message]).class.should == Indy
    end

    # http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PatternLayout.html
    it "should accept a log4j pattern string without error" do
      Indy.new(:log_format => ["%d [%M] %p %C{1} - %m", :time, :info, :class, :message]).class.should == Indy
    end

    it "should not raise error with non-conforming data" do
      @indy = Indy.new(:source => " \nfoobar\n\n baz", :log_format => ['([^\s]+) (\w+)', :time, :message])
      @indy.for(:all).class.should == Array
    end

    it "should accept time_format parameter" do
      @indy = Indy.new(:time_format => '%d-%m-%Y', :source => "1-13-2000 yes", :log_format => ['^([^\s]+) (\w+)$', :time, :message])
      @indy.for(:all).class.should == Array
      @indy.instance_variable_get(:@time_format).should == '%d-%m-%Y'
    end

    it "should accept an initialization hash passed to #search" do
      hash = {:time_format => '%d-%m-%Y',
        :source => "1-13-2000 yes",
        :log_format => ['^([^\s]+) (\w+)$', :time, :message]}
      @indy = Indy.search(hash)
      @indy.class.should == Indy
      @indy.for(:all).length.should == 1
    end


  end

  context 'instance' do

    before(:all) do
      @indy = Indy.new(:source => '1/2/2002 string', :log_format => ['([^\s]+) (\w+)', :time, :message])
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

  context ':search' do

    let(:log_file) { "#{File.dirname(__FILE__)}/data.log" }

    it "should be a class method" do
      Indy.should respond_to(:search)
    end

    it "should accept a string parameter" do
      Indy.search("String Log").class.should == Indy
    end

    it "should accept a :cmd symbol and a command string parameter" do
      Indy.search(:cmd =>"ls").class.should == Indy
    end

    it "should return an instance of Indy" do
      Indy.search("source string").should be_kind_of(Indy)
      Indy.search(:cmd => "ls").should be_kind_of(Indy)
    end

    it "should return an instance of Indy" do
      Indy.search(:source => {:cmd => 'ls'}, :log_format => Indy::DEFAULT_LOG_FORMAT).class.should == Indy
    end


    it "should create an instance of Indy::Source" do
      Indy.search("source string").instance_variable_get(:@source).should be_kind_of(Indy::Source)
    end

    it "the instance should have the source specified" do
      Indy.search("source string").source.should_not be_nil
      Indy.search(:cmd => "ls").source.should_not be_nil
    end

    it "the instance should raise an exception when passed an invalid source" do
      lambda{ Indy.search(nil) }.should raise_error Indy::Source::Invalid
    end

    it "the instance should raise an exception when passed an invalid source: nil" do
      lambda{ Indy.search(nil) }.should raise_error Indy::Source::Invalid
    end

    it "the instance should raise an exception when the arity is incorrect" do
      lambda{ Indy.search( ) }.should raise_error Indy::Source::Invalid
    end

    context "treat it second like a string" do

      it "should attempt to treat it as a string" do
        string = "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION."
        string_io = StringIO.new(string)
        StringIO.should_receive(:new).with(string).ordered.and_return(string_io)
        Indy.search(string).for(:application => 'MyApp').length.should == 1
      end

    end

    context "with explicit source hash" do

      context ":cmd" do

        it "should attempt open the command" do
          IO.stub!(:popen).with('ssh user@system "bash --login -c \"cat /var/log/standard.log\" "')
          Indy.search(:cmd => 'ssh user@system "bash --login -c \"cat /var/log/standard.log\" "')
        end

        it "should not throw an error for an invalid command" do
          IO.stub!(:popen).with('an invalid command').and_return('')
          Indy.search(:cmd => "an invalid command").class.should == Indy
        end

        it "should return an IO object upon a successful command" do
          IO.stub!(:popen).with("a command").and_return(StringIO.new("2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION."))
          Indy.search(:cmd => "a command").for(:application => 'MyApp').length.should == 1
        end

        it "should handle a real command" do
          cat_cmd = (is_windows? ? 'type' : 'cat')
          Indy.search(:cmd => "#{cat_cmd} #{log_file}").for(:application => 'MyApp').length.should == 2
        end

        it "should return an IO object upon a successful command" do
          IO.stub!(:popen).with("zzzzzzzzzzzz").and_return('Invalid command')
          lambda{ Indy.search(:cmd => "zzzzzzzzzzzz").for(:all) }.should raise_error( Indy::Source::Invalid, /Unable to open log source/)
        end

        it "should raise error for an invalid command" do
          lambda{ Indy.search(:cmd => "zzzzzzzzzzzz").for(:all) }.should raise_error( Indy::Source::Invalid, /Unable to open log source/)
        end

      end

      it ":file" do
        require 'tempfile'
        file = stub!(:size).and_return(1)
        lambda{ Indy.search(:file => file) }
      end

      it ":string" do
        string = "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION."
        string_io = StringIO.new(string)
        StringIO.should_receive(:new).with(string).ordered.and_return(string_io)
        Indy.search(:string => string).for(:application => 'MyApp').length.should == 1
      end

      it "should raise error when invalid" do
        lambda{ Indy.search(:foo => "a string").for(:all) }.should raise_error( Indy::Source::Invalid )
      end

    end

  end

  context "bad data" do

    before(:each) do
      log = "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n \n2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n bad \n2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n\n"
      @indy = Indy.search(log)
    end

    it "should find all 3 rows" do
      @indy.for(:all).length.should == 3
    end

  end

  context "multiline log mode" do

    before(:each) do
      log = [ "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION with data:\nfirst Application data.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              " ",
              "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION with data:\nApplication data.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION with data:\nApplications data\nMore data\n\tlast Application data."].join("\n")
      regexp = "^((#{Indy::LogFormats::DEFAULT_DATE_TIME})\\s+(#{Indy::LogFormats::DEFAULT_SEVERITY_PATTERN})\\s+(#{Indy::LogFormats::DEFAULT_APPLICATION})\\s+-\\s+(.*?)(?=#{Indy::LogFormats::DEFAULT_DATE_TIME}|\\z))"
      @indy = Indy.new(:source => log, :log_format => [regexp, :time,:severity,:application,:message], :multiline => true  )
    end

    it "should find the first row" do
      pending
      results = @indy.for(:all)
      results.first.message.should match(/first Application data.$/)
    end

    it "should find three INFO rows" do
      pending
      results = @indy.for(:severity => 'INFO').count.should == 3
    end

    it "should find the last row" do
      pending
      results = @indy.for(:all)
      results.last.message.should match(/\tlast Application data.$/)
      results.length.should == 5
    end

    it "should find using time based search" do
      pending
      results = @indy.before(:time => '2000-09-07 14:07:42', :inclusive => false).for(:all)
      results.length.should == 2
    end

  end

  context "support for blocks" do
    
    def log
      [ "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
    end
    
    it "should allow a block with :for and yield on each line of the results using :all" do
      actual_yield_count = 0
      Indy.search(log).for(:all) do |result|
        result.should be_kind_of(Struct::Line)
        actual_yield_count = actual_yield_count + 1
      end
      actual_yield_count.should == 3
    end

    it "should allow a block with :for and yield on each line of the results" do
      actual_yield_count = 0
      Indy.search(log).for(:severity => 'INFO') do |result|
        result.should be_kind_of(Struct::Line)
        actual_yield_count = actual_yield_count + 1
      end
      actual_yield_count.should == 2
    end

    it "should allow a block with :like and yield on each line of the results" do
      actual_yield_count = 0
      Indy.search(log).like(:message => '\be\S+ing') do |result|
        result.should be_kind_of(Struct::Line)
        actual_yield_count = actual_yield_count + 1
      end
      actual_yield_count.should == 2
    end

  end
  
  
  context "instance" do

    before(:each) do
      log = [ "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
      @indy = Indy.search(log)
    end

    it "with() should be a method" do
      @indy.should respond_to(:with)
    end

    it "with() should accept the log4r default pattern const without error" do
      @indy.with(Indy::LOG4R_DEFAULT_FORMAT).class.should == Indy
    end

    it "with() should accept :default without error" do
      @indy.with(:default).class.should == Indy
    end

    it "with() should use default log pattern when passed :default" do
      @indy.with(:default).for(:all).length.should == 3
    end

    it "with() should accept no params without error" do
      @indy.with().class.should == Indy
    end

    it "should return itself" do
      @indy.with(:default).should == @indy
    end

    [:for, :like, :matching].each do |method|
      it "#{method}() should exist" do
        @indy.should respond_to(method)
      end

      it "#{method}() should accept a hash of search criteria" do
        @indy.send(method,:severity => "INFO").class.should == Array
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
        @results.length.should == 3
        @results.first[:application].should == "MyApp"
      end

    end
  end

  context 'last_entry method' do

    before(:all) do
      @indy = Indy.search("2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n2000-09-07 14:07:42 INFO  MyApp - Entering APPLICATION.")
    end

    it "should return a Struct::Line object" do
      @indy.send(:last_entry).class.should == Struct::Line
    end

    it "should return correct Struct::Line objects" do
      @indy.send(:last_entry).time.should == '2000-09-07 14:07:42'
    end

  end

  context 'last_entries method' do

    before(:all) do
      @indy = Indy.search("2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n2000-09-07 14:07:42 INFO  MyApp - Entering APPLICATION.")
    end

    it "should return a an array of Struct::Line object" do
      @indy.send(:last_entries, 2).class.should == Array
      @indy.send(:last_entries, 2).first.class.should == Struct::Line
    end

    it "should return correct Struct::Line objects" do
      @indy.send(:last_entries, 2).first.time.should == '2000-09-07 14:07:42'
    end

  end

  context 'source' do
    before(:each) do
      @indy = Indy.search(
        [ "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.",
          "2000-09-07 14:08:41 INFO  MyApp - Initializing APPLICATION.",
          "2000-09-07 14:09:41 INFO  MyApp - Configuring APPLICATION.",
          "2000-09-07 14:10:50 INFO  MyApp - Running APPLICATION.",
          "2000-09-07 14:11:42 INFO  MyApp - Exiting APPLICATION.",
          "2000-09-07 14:12:15 INFO  MyApp - Exiting APPLICATION."
        ].join("\n") )
    end

    it "should know how many lines it contains" do
      @indy.source.send(:num_lines).should == 6
    end
  end

end
