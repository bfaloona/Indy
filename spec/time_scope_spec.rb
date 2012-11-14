require "#{File.dirname(__FILE__)}/helper"

describe Indy do

  context "search time scope" do

    before(:each) do
      @indy = Indy.search(
        [ "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.",
          "2000-09-07 14:07:42 INFO  MyApp - Initializing APPLICATION.",
          "2000-09-07 14:07:43 INFO  MyApp - Configuring APPLICATION.",
          "2000-09-07 14:07:44 INFO  MyApp - Running APPLICATION.",
          "2000-09-07 14:07:45 INFO  MyApp - Exiting APPLICATION."
        ].join("\n") )
    end

    context "after method" do

      it "should find the correct entries" do
        @indy.after(:time => '2000-09-07 14:07:42').all.length.should == 3
      end

      it "should find 0 entries with a time that is past the log" do
        @indy.after(:time => '2000-09-07 14:07:46').all.length.should == 0
      end

      it "should find all entries with a time that is before the log" do
        @indy.after(:time => '2000-09-07 14:07:40').all.length.should == 5
      end

      it "should find entries using inclusive" do
        @indy.after(:time => '2000-09-07 14:07:42', :inclusive => true).all.length.should == 4
      end

    end

    context "before method" do

      it "should find the correct entries" do
        @indy.before(:time => '2000-09-07 14:07:44').all.length.should == 3
      end

      it "should find 0 entries with a time that is before the log" do
        @indy.before(:time => '2000-09-07 14:07:40').all.length.should == 0
      end

      it "should find all entries with a time that is after the log" do
        @indy.before(:time => '2000-09-07 14:07:47').all.length.should == 5
      end

      it "should find entries using inclusive" do
        @indy.before(:time => '2000-09-07 14:07:44', :inclusive => true).all.length.should == 4
      end

    end

    context "within method" do

      it "should find the correct entries" do
        @indy.within(:start_time => '2000-09-07 14:07:41', :end_time => '2000-09-07 14:07:43').all.length.should == 1
      end

      it "should find the correct entries using inclusive" do
        @indy.within(:start_time => '2000-09-07 14:07:41', :end_time => '2000-09-07 14:07:43', :inclusive => true).all.length.should == 3
      end

    end

  end

  context "search time scopes with span" do

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

    it "using after should find the correct entries" do
      @indy.after(:time => '2000-09-07 14:07:42', :span => 1).all.length.should == 1
    end

    it "using before should find the correct entries" do
      @indy.before(:time => '2000-09-07 14:12:00', :span => 4).all.length.should == 4
    end

    it "using around should find the correct entries" do
      @indy.around(:time => '2000-09-07 14:11:00', :span => 2).all.length.should == 2
    end

    it "using after and inclusive should find the correct entries" do
      @indy.after(:time => '2000-09-07 14:07:41', :span => 2, :inclusive => true).all.length.should == 3
    end

  end

  context "multiple time scope methods on the same instance" do

    before(:each) do
      @indy = Indy.search(
        [ "2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.",
          "2000-09-07 14:07:42 INFO  MyApp - Initializing APPLICATION.",
          "2000-09-07 14:07:43 INFO  MyApp - Configuring APPLICATION.",
          "2000-09-07 14:07:44 INFO  MyApp - Running APPLICATION.",
          "2000-09-07 14:07:45 INFO  MyApp - Exiting APPLICATION."
        ].join("\n") )
    end

    # Issue #3 (by design) assumed that the time scope.
    it "should each add scope criteria to the instance" do
      @indy.after(:time => '2000-09-07 14:07:42').all.length.should == 3
      @indy.before(:time => '2000-09-07 14:07:45').all.length.should == 2
    end

    it "should specify the entire scope if #reset_scope was called" do
      @indy.after(:time => '2000-09-07 14:07:42').all.length.should == 3
      @indy.reset_scope
      @indy.before(:time => '2000-09-07 14:07:45').all.length.should == 4
    end

  end

  context "explicit :time_field handling" do

    it "should search within a time scope" do
      pending "Using explicit time_field is unsupported"
      pattern = "(\w+) (\d{4}-\d{2}-\d{2} \d{2}:) (\w+) - (.*)"
      @indy = Indy.new(
        :source => "INFO 2000-09-07 14:07:45 MyApp - Entering APPLICATION.\nINFO 2000-09-07 14:09:45 MyApp - Exiting APPLICATION.",
        :entry_regexp => pattern,
        :entry_fields => [:severity, :thetime, :application, :message],
        :time_field => :thetime)
      @indy.after(:time => '2000-09-07 14:08:00').all.first.thetime.should == '2000-09-07 14:09:45'
    end

  end

  context "explicit time format" do

    before(:each) do
      pattern = "^([^\s]+) (.*)$"
      @indy = Indy.new(:time_format => '%m-%d-%Y', 
        :source => "1-13-2002 message\n1-14-2002 another message\n1-15-2002 another message",
        :log_format => [pattern, :time, :message])
    end

    it "should search within time scope using a different format than explicitly set" do
      pending 'Flexible time date time formatting is not implemented'
      @indy.after(:time => 'Jan 13 2002').all.length.should == 2
      @indy.after(:time => 'Jan 14 2002').all.last._time.mday.should == 15
    end

  end

  it "should parse dates when log includes non-conforming data" do
    logdata = [ "12-03-2000 message1",
      "13-03-2000 message2",
      "14-03-2000 ",
      " message4",
      "a14-03-2000 message5",
      "14-03-2000 message6\n\n\n\n",
      "15-03-2000 message7",
      "16-03-2000 message8\r\n",
      "17-03-2000 message9"].join("\n")
    @indy = Indy.new(
      :source => logdata,
      :log_format => [/^(\d[^\s]+\d) (.+)$/, :time, :message])
    @indy.after(:time => '13-03-2000')
    @indy.all.length.should == 4
  end

end
