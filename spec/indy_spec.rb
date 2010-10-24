require 'lib/indy.rb'

describe Indy do

  context :initialize do

    it "should accept no arguments without error" do
      lambda { Indy.new }.should_not raise_error
    end

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

    context :for do

      it "should be a method" do
        @indy.should respond_to(:for)
      end
      
    end

  end

end