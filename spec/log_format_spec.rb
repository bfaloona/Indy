require "#{File.dirname(__FILE__)}/helper"

describe Indy do

  context "common logging format" do

    common_log_format = {
      :name => 'common_log_format',
      :source => ["127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] \"GET /apache_pb1.gif HTTP/1.0\" 200 2326",
                  "127.0.0.1 - louie [10/Oct/2000:13:55:37 -0700] \"GET /apache_pb2.gif HTTP/1.0\" 200 2327",
                  "127.0.0.1 - frank [10/Oct/2000:13:55:38 -0700] \"GET /apache_pb3.gif HTTP/1.0\" 404 300"].join("\n"),
      :regexp => Indy::LogFormats::COMMON_REGEXP,
      :fields => Indy::LogFormats::COMMON_FIELDS,
      :test_field => :authuser
    }

    combined_log_format = {
      :name => 'combined_log_format',
      :source => ["127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] \"GET /apache_pb1.gif HTTP/1.0\" 200 2326 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\"",
                  "127.0.0.1 - louie [10/Oct/2000:13:55:37 -0700] \"GET /apache_pb2.gif HTTP/1.0\" 200 2327 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\"",
                  "127.0.0.1 - frank [10/Oct/2000:13:55:38 -0700] \"GET /apache_pb3.gif HTTP/1.0\" 404 300 \"http://www.example.com/start.html\" \"Mozilla/4.08 [en] (Win98; I ;Nav)\""].join("\n"),
      :regexp => Indy::LogFormats::COMBINED_REGEXP,
      :fields => Indy::LogFormats::COMBINED_FIELDS,
      :test_field => :authuser
    }

    log4r_default_format = {
      :name => 'log4r_default_format',
      :source => ["DEBUG mylog: This is a message with level DEBUG",
                  " INFO mylog: This is a message with level INFO",
                  " WARN louie: This is a message with level WARN",
                  "ERROR mylog: This is a message with level ERROR",
                  "FATAL mylog: This is a message with level FATAL"].join("\n"),
      :regexp => Indy::LogFormats::LOG4R_DEFAULT_REGEXP,
      :fields => Indy::LogFormats::LOG4R_DEFAULT_FIELDS,
      :test_field => :application
    }
    
    [ common_log_format,
      combined_log_format,
      log4r_default_format ].each do |format|
      
      it "#{format[:name]} should work" do
        indy = Indy.new(:source => format[:source], :log_format => [format[:regexp],format[:fields]].flatten)
        result = indy.for(format[:test_field] => 'louie')
        result.length.should == 1
      end

      it "#{format[:name]} @pattern can be set to the Indy::LogFormat const" do
        indy = Indy.new(:source => format[:source], :log_format => eval('Indy::' + format[:name].upcase))
        result = indy.for(format[:test_field] => 'louie')
        result.length.should == 1

      end
    end
  end

end