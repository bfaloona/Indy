require "#{File.dirname(__FILE__)}/helper"

describe 'Indy' do

  context '#new' do

    it "should accept v0.3.4 initialization params" do
      indy_obj = Indy.new(:source => "foo\nbar\n").with(Indy::DEFAULT_LOG_FORMAT)
      search_obj = indy_obj.search
      search_obj.log_definition.class.should eq Indy::LogDefinition
      search_obj.log_definition.entry_regexp.class.should eq Regexp
      search_obj.log_definition.entry_fields.class.should eq Array
    end

    it "should not raise error with non-conforming data" do
      @indy = Indy.new(:source => " \nfoobar\n\n baz", :entry_regexp => '([^\s]+) (\w+)', :entry_fields => [:time, :message])
      @indy.all.class.should == Array
    end

    it "should accept time_format parameter" do
      @indy = Indy.new(:time_format => '%d-%m-%Y', :source => "1-13-2000 yes", :entry_regexp => '^([^\s]+) (\w+)$', :entry_fields => [:time, :message])
      @indy.all.class.should == Array
      @indy.search.log_definition.time_format.should == '%d-%m-%Y'
    end

    it "should accept an initialization hash passed to #search" do
      hash = {:time_format => '%d-%m-%Y',
        :source => "1-13-2000 yes",
        :entry_regexp => '^([^\s]+) (\w+)$',
        :entry_fields => [:time, :message]}
      @indy = Indy.search(hash)
      @indy.class.should == Indy
      @indy.all.length.should == 1
    end

  end

  context 'instance' do

    before(:each) do
      log = [ "2000-09-07 14:06:41 INFO MyApp - Entering APPLICATION.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
      @indy = Indy.search(log)
    end

    context "method" do

      it "#with should return self" do
        @indy.with().class.should == Indy
      end

      it "#with should use default log pattern when passed :default" do
        @indy.with(:default).all.length.should == 3
      end

      [:for, :like, :matching].each do |method|
        it "##{method} should exist" do
          @indy.should respond_to(method)
        end

        it "#{method} should accept a hash of search criteria" do
          @indy.send(method,:severity => "INFO").should be_kind_of(Array)
        end

        it "#{method} should return a set of results" do
          @indy.send(method,:severity => "DEBUG").should be_kind_of(Array)
        end
      end

      it "#last should return self" do
        @indy.last(:span => 1).should be_kind_of Indy
      end

      it "#last should set the time scope to the correct number of minutes" do
        @indy.last(:span => 1).all.count.should == 2
      end

      it "#last should raise an error if passed an invalid parameter" do
        lambda{ @indy.last('a') }.should raise_error( ArgumentError )
        lambda{ @indy.last() }.should raise_error( ArgumentError )
        lambda{ @indy.last(nil) }.should raise_error( ArgumentError )
        lambda{ @indy.last({}) }.should raise_error( ArgumentError )
      end

    end
  end

  context '#search' do

    it "should be a class method" do
      Indy.should respond_to(:search)
    end

    it "should accept a string parameter" do
      Indy.search("String Log").class.should == Indy
    end

    it "should accept a hash with :cmd key" do
      Indy.search(:cmd => "ls").class.should == Indy
    end

    it "should accept a hash with :file => filepath" do
      pending "Indy#search should be able to accept a :file => filepath hash"
      Indy.search(:file => "#{File.dirname(__FILE__)}/data.log").all.length.should == 2
    end

    it "should accept a hash with :file => File" do
      Indy.search(:file => File.open("#{File.dirname(__FILE__)}/data.log")).all.length.should == 2
    end

    it "should accept a valid :source hash" do
      Indy.search(:source => {:cmd => 'ls'}).class.should == Indy
    end

    it "should create an instance of Indy::Source in Search object" do
      Indy.search("source string").search.source.should be_kind_of(Indy::Source)
    end

    it "should raise an exception when passed an invalid source: nil" do
      lambda{ Indy.search(nil) }.should raise_error(Indy::Source::Invalid, /No source specified/)
    end

    it "should raise an exception when the arity is incorrect" do
      lambda{ Indy.search( ) }.should raise_error Indy::Source::Invalid
    end

    context "with explicit source hash" do

      context "using :cmd" do

        before(:all) do
          Dir.chdir(File.dirname(__FILE__))
        end

        it "should attempt open the command" do
          IO.stub!(:popen).with('ssh user@system "bash --login -c \"cat /var/log/standard.log\" "')
          Indy.search(:cmd => 'ssh user@system "bash --login -c \"cat /var/log/standard.log\" "')
        end

        it "should not throw an error for an invalid command" do
          IO.stub!(:popen).with('an invalid command').and_return('')
          Indy.search(:cmd => "an invalid command").class.should == Indy
        end

        it "should use IO.popen on cmd value" do
          IO.stub!(:popen).with("a command").and_return(StringIO.new("2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION."))
          Indy.search(:cmd => "a command").for(:application => 'MyApp').length.should == 1
        end

        it "should handle a real command" do
          log_file = "data.log"
          cat_cmd = (is_windows? ? 'type' : 'cat')
          Indy.search(:cmd => "#{cat_cmd} #{log_file}").for(:application => 'MyApp').length.should == 2
        end

        it "should raise Source::Invalid for an invalid command" do
          IO.stub!(:popen).with("zzzzzzzzzzzz").and_return('Invalid command')
          lambda{ Indy.search(:cmd => "zzzzzzzzzzzz").all }.should raise_error( Indy::Source::Invalid, /Unable to open log source/)
        end

      end

      it "using :file" do
        require 'tempfile'
        file = stub!(:size).and_return(1)
        lambda{ Indy.search(:file => file) }
      end

      it "using :string" do
        string = "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION."
        string_io = StringIO.new(string)
        StringIO.should_receive(:new).with(string).ordered.and_return(string_io)
        Indy.search(:string => string).for(:application => 'MyApp').length.should == 1
      end

      it "should raise error when given an invalid key" do
        lambda{ Indy.search(:foo => "a string").all }.should raise_error( Indy::Source::Invalid )
      end

    end

  end

  context "data handling" do

    it "should return all entries using #all" do
      log = [ "2000-09-07 14:06:41 INFO MyApp - Entering APPLICATION.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
      Indy.search(log).all.length.should == 3
    end

    it "should ignore invalid entries" do
      log = ["2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n \n",
            "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n",
            " bad \n",
            "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n\n"].join("\n")
      Indy.search(log).all.length.should == 3
    end

    it "should handle no matching entries" do
      log = ["2000-09-07   MyApp - Entering APPLICATION.\n \n",
            "2000-09-07 14:07:41\n"].join
      Indy.search(log).all.length.should == 0
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

    it "should return all entries using #all" do
      @indy.all.count.should == 5
    end

    it "should return correct number of entries with #for" do
      @indy.for(:severity => 'INFO').count.should == 3
    end

    it "should return correct number of entries with #like" do
      @indy.like(:message => 'ntering').count.should == 2
    end

    it "should return correct number of entries using #before time scope" do
      pending 'time scoped searches currently unsupported for multiline log formats'
      results = @indy.before(:time => '2000-09-07 14:07:42', :inclusive => false).all
      results.length.should == 2
    end

  end

  context "support for blocks" do
    
    def log
      [ "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION.",
        "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
        "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
    end
    
    it "with #for should yield Struct::Entry" do
      Indy.search(log).all do |result|
        result.should be_kind_of(Struct::Entry)
      end
    end

    it "with #for using :all should yield each entry" do
      actual_yield_count = 0
      Indy.search(log).all do |result|
        actual_yield_count += 1
      end
      actual_yield_count.should == 3
    end

    it "with #for should yield each entry" do
      actual_yield_count = 0
      Indy.search(log).for(:severity => 'INFO') do |result|
        actual_yield_count += 1
      end
      actual_yield_count.should == 2
    end

    it "with #like should yield each entry" do
      actual_yield_count = 0
      Indy.search(log).like(:message => '\be\S+ing') do |result|
        actual_yield_count += 1
      end
      actual_yield_count.should == 2
    end

  end
end
