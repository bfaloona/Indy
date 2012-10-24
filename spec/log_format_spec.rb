require "#{File.dirname(__FILE__)}/helper"

describe Indy do

  context "log format can be set to" do

    it Indy::COMMON_LOG_FORMAT do
      source = ["127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] \"GET /apache_pb1.gif HTTP/1.0\" 200 2326",
        "127.0.0.1 - frank [10/Oct/2000:13:55:37 -0700] \"GET /apache_pb1.gif HTTP/1.0\" 200 2326",
        "127.0.0.1 - louie [10/Oct/2000:13:55:37 -0700] \"GET /apache_pb2.gif HTTP/1.0\" 200 2327",
        "127.0.0.1 - frank [10/Oct/2000:13:55:38 -0700] \"GET /apache_pb3.gif HTTP/1.0\" 404 300"].join("\n")
      indy = Indy.new(:source => source, :log_format => Indy::COMMON_LOG_FORMAT)
      result = indy.for(:authuser => 'louie')
      result.length.should == 1
    end

    it Indy::COMBINED_LOG_FORMAT do
      source = ["127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] \"GET /apache_pb1.gif HTTP/1.0\" 200 2326 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\"",
        "127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] \"GET /apache_pb1.gif HTTP/1.0\" 200 2326 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\"",
        "127.0.0.1 - louie [10/Oct/2000:13:55:37 -0700] \"GET /apache_pb2.gif HTTP/1.0\" 200 2327 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\"",
        "127.0.0.1 - frank [10/Oct/2000:13:55:38 -0700] \"GET /apache_pb3.gif HTTP/1.0\" 404 300 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\""].join("\n")
      indy = Indy.new(:source => source, :log_format => Indy::COMBINED_LOG_FORMAT)
      result = indy.for(:authuser => 'louie')
      result.length.should == 1
    end

    it Indy::LOG4R_DEFAULT_FORMAT do
      source = ["DEBUG mylog: This is a message with level DEBUG",
        " INFO mylog: This is a message with level INFO",
        " WARN louie: This is a message with level WARN",
        "ERROR mylog: This is a message with level ERROR",
        "FATAL mylog: This is a message with level FATAL"].join("\n")
      indy = Indy.new(:source => source, :log_format => Indy::LOG4R_DEFAULT_FORMAT)
      result = indy.for(:application => 'louie')
      result.length.should == 1
    end

  end

  # http://log4r.rubyforge.org/rdoc/Log4r/rdoc/patternformatter.html
  it "should accept a log4r pattern string without error" do
    Indy.new(:entry_regexp => "(%d) (%i) (%c) - (%m)", :entry_fields => [:time, :info, :class, :message]).class.should == Indy
  end

  # http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PatternLayout.html
  it "should accept a log4j pattern string without error" do
    Indy.new(:entry_regexp => "%d [%M] %p %C{1} - %m", :entry_fields => [:time, :info, :class, :message]).class.should == Indy
  end

end