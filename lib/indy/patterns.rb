class Indy

  #
  # Indy default log format @pattern
  # e.g.:
  # INFO 2000-09-07 MyApp - Entering APPLICATION.
  #
  DEFAULT_LOG_PATTERN = [LogFormats::DEFAULT_LOG_REGEXP, LogFormats::DEFAULT_LOG_FIELDS].flatten

  #
  # Uncustomized Log4r log @pattern
  #
  LOG4R_DEFAULT_PATTERN = [LogFormats::LOG4R_DEFAULT_REGEXP, LogFormats::LOG4R_DEFAULT_FIELDS].flatten

  #
  # NCSA Common Log Format log @pattern
  #
  COMMON_LOG_PATTERN = [LogFormats::COMMON_REGEXP, LogFormats::COMMON_FIELDS].flatten

  #
  # NCSA Combined Log Format log @pattern
  #
  COMBINED_LOG_PATTERN = [LogFormats::COMBINED_REGEXP, LogFormats::COMBINED_FIELDS].flatten

end
