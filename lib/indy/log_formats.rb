class Indy

  #
  # LogFormats defines the building blocks of Indy's built in log patterns.
  #
  # See indy/patterns.rb for the following Constants:
  # Indy::COMMON_LOG_PATTERN
  # Indy::COMBINED_LOG_PATTERN
  # Indy::LOG4R_DEFAULT_PATTERN
  #
  module LogFormats

    IPV4_REGEXP = '(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3})'
    SPACE_DELIM_REGEXP = '([^\s]+)'
    BRACKET_DELIM_REGEXP = '\[([^\]]+)\]'
    HTTP_REQUEST_REGEXP = '"([A-Z]+ [^\s]+ [^"]+)"'
    HTTP_STATUS_REGEXP = '(\d{3})'
    NUMBER_REGEXP = '(\d+)'
    DQUOTE_DELIM_REGEXP = '"([^"]+)"'

    DEFAULT_DATE_TIME = '\d{4}.\d{2}.\d{2}\s+\d{2}.\d{2}.\d{2}' #"%Y-%m-%d %H:%M:%S"
    DEFAULT_SEVERITY = [:trace,:debug,:info,:warn,:error,:fatal]
    DEFAULT_SEVERITY_PATTERN = "(?:#{DEFAULT_SEVERITY.map{|s| s.to_s.upcase}.join("|")})"
    DEFAULT_APPLICATION = '\w+'
    DEFAULT_MESSAGE = '.+'

    DEFAULT_LOG_REGEXP = /^(#{DEFAULT_DATE_TIME})\s+(#{DEFAULT_SEVERITY_PATTERN})\s+(#{DEFAULT_APPLICATION})\s+-\s+(#{DEFAULT_MESSAGE})$/
    DEFAULT_LOG_FIELDS = [:time,:severity,:application,:message]

    COMMON_FIELDS = [:host, :ident, :authuser, :time, :request, :status, :bytes]
    COMMON_REGEXP = /^#{IPV4_REGEXP} #{SPACE_DELIM_REGEXP} #{SPACE_DELIM_REGEXP} #{BRACKET_DELIM_REGEXP} #{DQUOTE_DELIM_REGEXP} #{HTTP_STATUS_REGEXP} #{NUMBER_REGEXP}$/

    COMBINED_FIELDS = COMMON_FIELDS + [:referrer, :user_agent]
    COMBINED_REGEXP = /^#{IPV4_REGEXP} #{SPACE_DELIM_REGEXP} #{SPACE_DELIM_REGEXP} #{BRACKET_DELIM_REGEXP} #{DQUOTE_DELIM_REGEXP} #{HTTP_STATUS_REGEXP} #{NUMBER_REGEXP} #{DQUOTE_DELIM_REGEXP} #{DQUOTE_DELIM_REGEXP}$/

    LOG4R_DEFAULT_FIELDS = [:level, :application, :message]
    LOG4R_DEFAULT_REGEXP = /(?:\s+)?([A-Z]+) (\S+): (.*)$/
  end
end