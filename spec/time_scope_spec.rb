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
        expect(@indy.after(:time => '2000-09-07 14:07:42').all.length).to eq(3)
      end

      it "should find 0 entries with a time that is past the log" do
        expect(@indy.after(:time => '2000-09-07 14:07:46').all.length).to eq(0)
      end

      it "should find all entries with a time that is before the log" do
        expect(@indy.after(:time => '2000-09-07 14:07:40').all.length).to eq(5)
      end

      it "should find entries using inclusive" do
        expect(@indy.after(:time => '2000-09-07 14:07:42', :inclusive => true).all.length).to eq(4)
      end

    end

    context "before method" do

      it "should find the correct entries" do
        expect(@indy.before(:time => '2000-09-07 14:07:44').all.length).to eq(3)
      end

      it "should find 0 entries with a time that is before the log" do
        expect(@indy.before(:time => '2000-09-07 14:07:40').all.length).to eq(0)
      end

      it "should find all entries with a time that is after the log" do
        expect(@indy.before(:time => '2000-09-07 14:07:47').all.length).to eq(5)
      end

      it "should find entries using inclusive" do
        expect(@indy.before(:time => '2000-09-07 14:07:44', :inclusive => true).all.length).to eq(4)
      end

    end

    context "within method" do

      it "should find the correct entries" do
        expect(@indy.within(:start_time => '2000-09-07 14:07:41', :end_time => '2000-09-07 14:07:43').all.length).to eq(1)
      end

      it "should find the correct entries using inclusive" do
        expect(@indy.within(:start_time => '2000-09-07 14:07:41', :end_time => '2000-09-07 14:07:43', :inclusive => true).all.length).to eq(3)
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
      expect(@indy.after(:time => '2000-09-07 14:07:42', :span => 1).all.length).to eq(1)
    end

    it "using before should find the correct entries" do
      expect(@indy.before(:time => '2000-09-07 14:12:00', :span => 4).all.length).to eq(4)
    end

    it "using around should find the correct entries" do
      expect(@indy.around(:time => '2000-09-07 14:11:00', :span => 2).all.length).to eq(2)
    end

    it "using after and inclusive should find the correct entries" do
      expect(@indy.after(:time => '2000-09-07 14:07:41', :span => 2, :inclusive => true).all.length).to eq(3)
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
      expect(@indy.after(:time => '2000-09-07 14:07:42').all.length).to eq(3)
      expect(@indy.before(:time => '2000-09-07 14:07:45').all.length).to eq(2)
    end

    it "should specify the entire scope if #reset_scope was called" do
      expect(@indy.after(:time => '2000-09-07 14:07:42').all.length).to eq(3)
      @indy.reset_scope
      expect(@indy.before(:time => '2000-09-07 14:07:45').all.length).to eq(4)
    end

  end

  context "explicit time format" do

    before(:each) do
      @indy = Indy.new(
          :time_format => '[%m %d %Y]',
          :source => "[1 13 2002] message\n[1 14 2002] another message\n[1 15 2002] another message",
          :entry_regexp => "^(\\[.+\\]) (.*)$",
          :entry_fields => [:time, :message])
    end

    it "using before finds correct number of entries" do
      expect(@indy.before(:time => '[1 14 2002]').all.length).to eq(1)
    end

    it "using default (not explicit) time format finds correct number of entries" do
      expect(@indy.after(:time => '2002-01-13').all.length).to eq(2)
    end

  end

  it "should raise ParseException when log includes non-conforming data" do
    logdata = [ "12-03-2000 message1",
      "13-03-2000 message2",
      "14-03-2000 ",
      " message4",
      "16-03-2000 message6\n\n\n\n",
      "a17-03-2000 message5",
      "18-03-2000 message7",
      "19-03-2000 message8\r\n",
      "20-03-2000 message9"].join("\n")
    @indy = Indy.new(
      :source => logdata,
      :log_format => [/^(\d[^\s]+\d) (.+)$/, :time, :message])
    @indy.after(:time => '16-03-2000')
    expect{
      @indy.all
    }.to raise_exception( Indy::Time::ParseException )
  end

end
