require "#{File.dirname(__FILE__)}/helper"

describe Indy do

  context "log format can be set to" do

    it 'Indy::COMMON_LOG_FORMAT' do
      source = ["127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] \"GET /apache_pb1.gif HTTP/1.0\" 200 2326",
        "127.0.0.1 - frank [10/Oct/2000:13:55:37 -0700] \"GET /apache_pb1.gif HTTP/1.0\" 200 2326",
        "127.0.0.1 - louie [10/Oct/2000:13:55:37 -0700] \"GET /apache_pb2.gif HTTP/1.0\" 200 2327",
        "127.0.0.1 - frank [10/Oct/2000:13:55:38 -0700] \"GET /apache_pb3.gif HTTP/1.0\" 404 300"].join("\n")
      indy = Indy.new(:source => source).with(Indy::COMMON_LOG_FORMAT)
      result = indy.for(:authuser => 'louie')
      expect(result.length).to eq(1)
    end

    it 'Indy::COMBINED_LOG_FORMAT' do
      source = ["127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] \"GET /apache_pb1.gif HTTP/1.0\" 200 2326 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\"",
        "127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] \"GET /apache_pb1.gif HTTP/1.0\" 200 2326 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\"",
        "127.0.0.1 - louie [10/Oct/2000:13:55:37 -0700] \"GET /apache_pb2.gif HTTP/1.0\" 200 2327 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\"",
        "127.0.0.1 - frank [10/Oct/2000:13:55:38 -0700] \"GET /apache_pb3.gif HTTP/1.0\" 404 300 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\""].join("\n")
      indy = Indy.new(:source => source).with(Indy::COMBINED_LOG_FORMAT)
      result = indy.for(:authuser => 'louie')
      expect(result.length).to eq(1)
    end

    it 'Indy::LOG4R_DEFAULT_FORMAT' do
      # http://log4r.rubyforge.org/rdoc/Log4r/rdoc/patternformatter.html
      source = ["DEBUG mylog: This is a message with level DEBUG",
        " INFO mylog: This is a message with level INFO",
        " WARN louie: This is a message with level WARN",
        "ERROR mylog: This is a message with level ERROR",
        "FATAL mylog: This is a message with level FATAL"].join("\n")
      indy = Indy.new(:source => source)
      indy.with(Indy::LOG4R_DEFAULT_FORMAT)
      result = indy.for(:application => 'louie')
      expect(result.length).to eq(1)
    end

    it 'Indy::LOG4J_DEFAULT_FORMAT' do
      # http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PatternLayout.html
      source = ["This is a message with level DEBUG",
        "This is a message with level INFO",
        "This is a message with level WARN",
        "This is a message with level ERROR",
        "This is a message with level FATAL"].join("\n")
      indy = Indy.new(:source => source).with(Indy::LOG4J_DEFAULT_FORMAT)
      expect(indy.all.length).to eq(5)
    end

  end

  # http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/TTCCLayout.html
  # example:
  # 176 [main] INFO  org.apache.log4j.examples.Sort - Populating an array of 2 elements in reverse order.
  it "should accept a log4j TTCC layout regex without error" do
    log_data =
"343 [main] INFO  org.apache.log4j.examples.Sort - The next log statement should be an error message.
346 [main] ERROR org.apache.log4j.examples.SortAlgo.DUMP - Tried to dump an uninitialized array.
        at org.apache.log4j.examples.SortAlgo.dump(SortAlgo.java:58)
        at org.apache.log4j.examples.Sort.main(Sort.java:64)
467 [main] INFO  org.apache.log4j.examples.Sort - Exiting main method."

    expect(Indy.new( :source => log_data,
              :entry_regexp => /^(\d{3})\s+\[(\S+)\]\s+(\S+)\s+(\S+)\s*([^-]*)\s*-\s+(.+?)(?=\n\d{3}|\Z)/m,
              :entry_fields => [:time, :thread, :level, :category, :diagnostic, :message]
            ).class).to eq(Indy)
  end

end