require "#{File.dirname(__FILE__)}/helper"

describe 'Indy' do

  context '#new' do

    it "should accept v0.3.4 initialization params" do
      indy_obj = Indy.new(:source => "foo\nbar\n").with(Indy::DEFAULT_LOG_FORMAT)
      search_obj = indy_obj.search
      expect(search_obj.source.log_definition.class).to eq Indy::LogDefinition
      expect(search_obj.source.log_definition.entry_regexp.class).to eq Regexp
      expect(search_obj.source.log_definition.entry_fields.class).to eq Array
    end

    it "should not raise error with non-conforming data" do
      @indy = Indy.new(:source => " \nfoobar\n\n baz", :entry_regexp => '([^\s]+) (\w+)', :entry_fields => [:time, :message])
      expect(@indy.all.class).to eq(Array)
    end

    it "should accept time_format parameter" do
      @indy = Indy.new(:time_format => '%d-%m-%Y', :source => "1-13-2000 yes", :entry_regexp => '^([^\s]+) (\w+)$', :entry_fields => [:time, :message])
      expect(@indy.all.class).to eq(Array)
      expect(@indy.search.source.log_definition.time_format).to eq('%d-%m-%Y')
    end

    it "should accept an initialization hash passed to #search" do
      hash = {:time_format => '%d-%m-%Y',
        :source => "1-13-2000 yes",
        :entry_regexp => '^([^\s]+) (\w+)$',
        :entry_fields => [:time, :message]}
      @indy = Indy.search(hash)
      expect(@indy.class).to eq(Indy)
      expect(@indy.all.length).to eq(1)
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
        expect(@indy.with().class).to eq(Indy)
      end

      it "#with should use default log pattern when passed :default" do
        expect(@indy.with(:default).all.length).to eq(3)
      end

      it "should raise Exception when regexp captures don't match fields" do
        log = [ "2000-09-07 14:06:41 INFO MyApp - Entering APPLICATION.",
                "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION."].join("\n")
        expect{
          expect(Indy.search(log).
                    with(:entry_regexp => Indy::LogFormats::DEFAULT_ENTRY_REGEXP,
                         :entry_fields => [:field_one]
                        ).all.length).to be > 0
        }.to raise_error Indy::Source::FieldMismatchException
      end

      [:for, :like, :matching].each do |method|
        it "##{method} should exist" do
          expect(@indy).to respond_to(method)
        end

        it "##{method} should accept a hash of search criteria" do
          expect(@indy.send(method,:severity => "INFO")).to be_a_kind_of(Array)
        end

        it "##{method} should return a set of results" do
          expect(@indy.send(method,:severity => "DEBUG")).to be_a_kind_of(Array)
        end
      end

      it "#last should return self" do
        expect(@indy.last(:span => 1)).to be_a_kind_of Indy
      end

      it "#last should set the time scope to the correct number of minutes" do
        expect(@indy.last(:span => 1).all.count).to eq(2)
      end

      it "#last should raise an error if passed an invalid parameter" do
        expect{ @indy.last('a') }.to raise_error( ArgumentError )
        expect{ @indy.last() }.to raise_error( ArgumentError )
        expect{ @indy.last(nil) }.to raise_error( ArgumentError )
        expect{ @indy.last({}) }.to raise_error( ArgumentError )
      end

    end
  end

  context '#search' do

    it "should be a class method" do
      expect(Indy).to respond_to(:search)
    end

    it "should accept a string parameter" do
      expect(Indy.search("String Log").class).to eq(Indy)
    end

    it "should accept a hash with :cmd key" do
      expect(Indy.search(:cmd => "ls").class).to eq(Indy)
    end

    it "should accept a hash with :file => filepath" do
      expect(Indy.search(:file => "#{File.dirname(__FILE__)}/data.log").all.length).to eq(2)
    end

    it "should accept a hash with :file => File" do
      expect(Indy.search(:file => File.open("#{File.dirname(__FILE__)}/data.log")).all.length).to eq(2)
    end

    it "should accept a valid :source hash" do
      expect(Indy.search(:source => {:cmd => 'ls'}).class).to eq(Indy)
    end

    it "should create an instance of Indy::Source in Search object" do
      expect(Indy.search("source string").search.source).to be_kind_of(Indy::Source)
    end

    it "should raise an exception when passed an invalid source: nil" do
      expect{ Indy.search(nil) }.to raise_error(Indy::Source::Invalid, /No source specified/)
    end

    it "should raise an exception when the arity is incorrect" do
      expect{ Indy.search( ) }.to raise_error Indy::Source::Invalid
    end

    context "with explicit source hash" do

      context "using :cmd" do

        before(:all) do
          Dir.chdir(File.dirname(__FILE__))
        end

        it "should attempt open the command" do
          allow(IO).to receive(:popen).with('ssh user@system "bash --login -c \"cat /var/log/standard.log\" "')
          Indy.search(:cmd => 'ssh user@system "bash --login -c \"cat /var/log/standard.log\" "')
        end

        it "should not throw an error for an invalid command" do
          allow(IO).to receive(:popen).with('an invalid command').and_return('')
          expect(Indy.search(:cmd => "an invalid command").class).to eq(Indy)
        end

        it "should use IO.popen on cmd value" do
          allow(IO).to receive(:popen).with("a command").and_return(StringIO.new("2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION."))
          expect(Indy.search(:cmd => "a command").for(:application => 'MyApp').length).to eq(1)
        end

        it "should handle a real command" do
          log_file = "data.log"
          cat_cmd = (is_windows? ? 'type' : 'cat')
          expect(Indy.search(:cmd => "#{cat_cmd} #{log_file}").for(:application => 'MyApp').length).to eq(2)
        end

        it "should raise Source::Invalid for an invalid command" do
          allow(IO).to receive(:popen).with("zzzzzzzzzzzz").and_return('Invalid command')
          expect{ Indy.search(:cmd => "zzzzzzzzzzzz").all }.to raise_error( Indy::Source::Invalid, /Unable to open log source/)
        end

      end

      it "using :file" do
        expect(Indy.search(:file => "#{File.dirname(__FILE__)}/data.log").all.length).to eq(2)
      end

      it "using :string" do
        string = "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION."
        string_io = StringIO.new(string)
        expect(StringIO).to receive(:new).with(string).ordered.and_return(string_io)
        expect(Indy.search(:string => string).for(:application => 'MyApp').length).to eq(1)
      end

      it "should raise error when given an invalid key" do
        expect{ Indy.search(:foo => "a string").all }.to raise_error( Indy::Source::Invalid )
      end

    end

  end

  context "data handling" do

    it "should return all entries using #all" do
      log = [ "2000-09-07 14:06:41 INFO MyApp - Entering APPLICATION.",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION.",
              "2000-09-07 14:07:43 INFO MyApp - Exiting APPLICATION."].join("\n")
      expect(Indy.search(log).all.length).to eq(3)
    end

    it "should ignore invalid entries" do
      log = ["2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n \n",
            "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n",
            " bad \n",
            "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.\n\n"].join("\n")
      expect(Indy.search(log).all.length).to eq(3)
    end

    it "should handle no matching entries" do
      log = ["2000-09-07   MyApp - Entering APPLICATION.\n \n",
            "2000-09-07 14:07:41\n"].join
      expect(Indy.search(log).all.length).to eq(0)
    end

    context "with explicit time format" do

      it "returns correct number of records" do
        log = ["09-2000-07 INFO  MyApp - Entering APPLICATION.\n \n",
               "09-2000-07 INFO  MyApp - Opening APPLICATION.\n",
               "2000-09-07 INFO  MyApp - Invalid Entry\n"].join
        indy = Indy.new(:source => log,
                        :time_format => '%d-%Y-%m',
                        :entry_regexp => /^(\d\d-\d\d\d\d-\d\d)\s+(#{Indy::LogFormats::DEFAULT_SEVERITY_PATTERN})\s+(#{Indy::LogFormats::DEFAULT_APPLICATION})\s+-\s+(#{Indy::LogFormats::DEFAULT_MESSAGE})$/,
                        :entry_fields => Indy::LogFormats::DEFAULT_ENTRY_FIELDS)
        expect(indy.all.length).to eq(2)
      end
    end

  end

  context "multiline log mode" do

    before(:each) do
      log = [ "2000-09-07 14:07:41 INFO MyApp - Entering APPLICATION with data:\nfirst Application data. AAA",
              "2000-09-07 14:07:42 DEBUG MyApp - Initializing APPLICATION. BBB",
              "2000-09-07 14:07:43 INFO MyApp - Entering APPLICATION with data:\nApplication data. CCC",
              "2000-09-07 14:07:44 DEBUG MyApp - Initializing APPLICATION. DDD",
              "2000-09-07 14:07:45 INFO MyApp - Exiting APPLICATION with data:\nApplications data\nMore data\n\tlast Application data. EEE"].join("\n")
      regexp = "^((#{Indy::LogFormats::DEFAULT_DATE_TIME})\\s+(#{Indy::LogFormats::DEFAULT_SEVERITY_PATTERN})\\s+(#{Indy::LogFormats::DEFAULT_APPLICATION})\\s+-\\s+(.*?)(?=#{Indy::LogFormats::DEFAULT_DATE_TIME}|\\z))"
      @indy = Indy.new(:source => log, :log_format => [regexp, :time,:severity,:application,:message], :multiline => true  )
    end

    it "should return all entries using #all" do
      expect(@indy.all.count).to eq(5)
    end

    it "should return correct number of entries with #for" do
      expect(@indy.for(:severity => 'INFO').count).to eq(3)
    end

    it "should return correct number of entries with #like" do
      expect(@indy.like(:message => 'ntering').count).to eq(2)
    end

    it "should return correct number of entries using #after time scope" do
      results = @indy.after(:time => '2000-09-07 14:07:43', :inclusive => false).all
      expect(results.length).to eq(2)
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
        expect(result).to be_a_kind_of(Struct::Entry)
      end
    end

    it "with #for using :all should yield each entry" do
      actual_yield_count = 0
      Indy.search(log).all do |result|
        actual_yield_count += 1
      end
      expect(actual_yield_count).to eq(3)
    end

    it "with #for should yield each entry" do
      actual_yield_count = 0
      Indy.search(log).for(:severity => 'INFO') do |result|
        actual_yield_count += 1
      end
      expect(actual_yield_count).to eq(2)
    end

    it "with #like should yield each entry" do
      actual_yield_count = 0
      Indy.search(log).like(:message => '\be\S+ing') do |result|
        actual_yield_count += 1
      end
      expect(actual_yield_count).to eq(2)
    end

  end
end
