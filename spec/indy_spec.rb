require "#{File.dirname(__FILE__)}/helper"

describe Indy do

  context :initialize do

    # http://log4r.rubyforge.org/rdoc/Log4r/rdoc/patternformatter.html
    it "should accept a log4r pattern string without error" do
      lambda { Indy.new(:pattern => "%d %i %c - %m") }.should_not raise_error
    end

    # http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PatternLayout.html
    it "should accept a log4j pattern string without error" do
      lambda { Indy.new(:pattern => "%d [%M] %p %C{1} - %m")}
    end
    
  end

  context :search do

    it "should be a method" do
      Indy.should respond_to(:search)
    end

    it "should accept a string parameter" do
      Indy.search("String Log")
    end

    it "should return an instance of Indy" do
      Indy.search("source string").should be_kind_of(Indy)
    end

    it "the instance should have the source specified" do
      Indy.search("source string").source.should == "source string"
    end
  end

  context "instance" do

    before(:each) do
      @indy = Indy.search("source string")
    end

    context :with do

      it "should be a method" do
        @indy.should respond_to(:with)
      end

      # http://log4r.rubyforge.org/rdoc/Log4r/rdoc/patternformatter.html
      it "should accept a log4r pattern string without error" do
        lambda { @indy.with("%d %i %c - %m") }.should_not raise_error
      end

      # http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PatternLayout.html
      it "should accept a log4j pattern string without error" do
        lambda { @indy.with("%d [%M] %p %C{1} - %m")}.should_not raise_error
      end

      it "should return itself" do
        @indy.with("log pattern").should == @indy
      end

    end

    context "method" do

      [:for, :search, :like ].each do |method|
        it "#{method} should exist" do
          @indy.should respond_to(method)
        end

        it "#{method} should accept a hash of search criteria" do
          lambda { @indy.send(method,:severity => "INFO") }.should_not raise_error
        end

        it "#{method} should return a set of results" do
          @indy.send(method,:severity => "DEBUG").should be_kind_of(Array)
        end
      end

    end

    context "search" do

      it "should call _search with the parameter and value passed to it" do

      end


    end

    context "_search when given source, param and value" do

      before(:each) do
        @results = @indy._search("2000-09-07 14:07:41 INFO  MyApp - Entering APPLICATION.",[Indy::DEFAULT_LOG_PATTERN, Indy::DEFAULT_LOG_FIELDS].flatten) {|result| result if result[:application] == "MyApp" }
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