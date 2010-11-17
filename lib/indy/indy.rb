

class Indy

  attr_accessor :source, :pattern

  DATE_TIME = "\\d{4}.\\d{2}.\\d{2}\s+\\d{2}.\\d{2}.\\d{2}" #"%Y-%m-%d %H:%M:%S"
  SEVERITY = [:trace,:debug,:info,:warn,:error,:fatal]
  SEVERITY_PATTERN = "(?:#{SEVERITY.map{|s| s.to_s.upcase}.join("|")})"
  APPLICATION = "\\w+"
  MESSAGE = ".+"
  DEFAULT_LOG_PATTERN = "^(#{DATE_TIME})\\s+(#{SEVERITY_PATTERN})\\s+(#{APPLICATION})\\s+-\\s+(#{MESSAGE})$"

  def initialize(args)
    @source = @pattern = nil

    while (arg = args.shift) do
      send("#{arg.first}=",arg.last)
    end
  end

  class << self

    #
    # Create a new instance of Indy with the source specified.  This allows for
    # a more fluent creation that moves into the execution.
    #
    # @example
    #
    #   Indy.search("apache.log").for(:severity => "INFO")
    #
    def search(source)
      Indy.new(:source => source, :pattern => DEFAULT_LOG_PATTERN)
    end

  end

  #
  # Specify the log pattern to use as the comparison against each line within
  # the log file that has been specified.
  #
  # @param [String] log_pattern a string representation of the regular expression
  #        to use for comparison against each log line.
  #
  def with(log_pattern=:default)
    @pattern = log_pattern == :default ? DEFAULT_LOG_PATTERN : log_pattern
    self
  end

  #
  # Search the source and make an == comparison
  #
  # @param [Hash] search_criteria the field to search for as the key and the
  #        value to compare against the other log messages
  #
  def search(search_criteria)
    results = ResultSet.new

    while (criteria = search_criteria.shift)
      results += _search(@source,@pattern) {|result| result if result.send(criteria.first) == criteria.last }
    end

    results
  end

  #
  # Search the source and make a regular expression comparison
  #
  # @param [Hash] search_criteria the field to search for as the key and the
  #        value to compare against the other log messages
  #
  def like(search_criteria)
    results = ResultSet.new

    while (criteria = search_criteria.shift)
      results += _search(@source,@pattern) {|result| result if result.send(criteria.first) =~ /#{criteria.last}/ }
    end

    results
  end

  #
  # Search the source for the specific severity
  #
  # @param [String,Symbol] severity the severity of the log messages to search
  #        for within the source
  # @param [Symbol] direction by default search at the severity level, but you
  #        can specify :equal, :equal_and_above, and :equal_and_below
  #
  def severity(severity,direction=:equal)
    severity = severity.to_s.downcase.to_sym

    case direction
    when :equal
      severity = [severity]
    when :equal_and_above
      severity = SEVERITY[SEVERITY.index(severity)..-1]
    when :equal_and_below
      severity = SEVERITY[0..SEVERITY.index(severity)]
    end

    ResultSet.new + _search(@source,@pattern) {|result| result if severity.include?(result.severity.downcase.to_sym) }

  end

  alias_method :for, :search

  #
  # Search the specified source and yield to the block the line that was found
  # with the given log pattern
  #
  # This method is suppose to be used internally.
  #
  def _search(source,pattern,&block)
    results = source.split("\n").collect do |line|
      if /#{pattern}/.match(line)
        result = Result.new(line,$1, $2, $3, $4) #date_time, severity, application, message
        block_given? ? block.call(result) : nil
      end
    end

    results.compact
  end

end