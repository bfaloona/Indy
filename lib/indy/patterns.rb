class Indy

  #
  # @pattern for Indy default log format
  # e.g.:
  # INFO 2000-09-07 MyApp - Entering APPLICATION.
  #
  DEFAULT_LOG_PATTERN = [LogFormats::DEFAULT_LOG_REGEXP, LogFormats::DEFAULT_LOG_FIELDS].flatten

  #
  # @pattern for uncustomized Log4r logs
  #
  LOG4R_DEFAULT_PATTERN = [LogFormats::LOG4R_DEFAULT_REGEXP, LogFormats::LOG4R_DEFAULT_FIELDS].flatten

  #
  # @pattern for NCSA Common Log Format logs
  #
  COMMON_LOG_PATTERN = [LogFormats::COMMON_REGEXP, LogFormats::COMMON_FIELDS].flatten

  #
  # @pattern for NCSA Combined Log Format logs
  #
  COMBINED_LOG_PATTERN = [LogFormats::COMBINED_REGEXP, LogFormats::COMBINED_FIELDS].flatten

end
