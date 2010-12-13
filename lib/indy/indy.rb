require 'ostruct'

class Indy

  attr_accessor :source, :pattern

  DATE_TIME = "\\d{4}.\\d{2}.\\d{2}\s+\\d{2}.\\d{2}.\\d{2}" #"%Y-%m-%d %H:%M:%S"
  SEVERITY = [:trace,:debug,:info,:warn,:error,:fatal]
  SEVERITY_PATTERN = "(?:#{SEVERITY.map{|s| s.to_s.upcase}.join("|")})"
  APPLICATION = "\\w+"
  MESSAGE = ".+"
  DEFAULT_LOG_PATTERN = "^(#{DATE_TIME})\\s+(#{SEVERITY_PATTERN})\\s+(#{APPLICATION})\\s+-\\s+(#{MESSAGE})$"
  DEFAULT_LOG_FIELDS = [:time,:severity,:application,:message]
  
  #
  # Initialize Indy.
  #
  # @example
  #
  #  Indy.new(:source => LOG_FILE)
  #  Indy.new(:source => LOG_FILE,:pattern => [LOG_REGEX_PATTERN,:time,:application,:message]
  #
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
      Indy.new(:source => source, :pattern => [DEFAULT_LOG_PATTERN,DEFAULT_LOG_FIELDS].flatten)
    end

  end

  #
  # Specify the log pattern to use as the comparison against each line within
  # the log file that has been specified.
  #
  # @param [Array] pattern_array an Array with the regular expression as the first element
  #        followed by list of fields (Symbols) in the log entry
  #        to use for comparison against each log line.
  #
  # @example Log formatted as - HH:MM:SS Message
  #   
  #  Indy.search(LOG_FILE).with("^(\\d{2}.\\d{2}.\\d{2})\s*(.+)$",:time,:message)
  #
  def with(pattern_array = :default)
    @pattern = pattern_array == :default ? [DEFAULT_LOG_PATTERN,DEFAULT_LOG_FIELDS].flatten : pattern_array
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

    results += _search do |result|
      OpenStruct.new(result) if search_criteria.reject {|criteria,value| result[criteria] == value }.empty?
    end

    results
  end
  
  alias_method :for, :search

  #
  # Search the source and make a regular expression comparison
  #
  # @param [Hash] search_criteria the field to search for as the key and the
  #        value to compare against the other log messages
  #
  # @example For all applications that end with Service
  #
  #  Indy.search(LOG_FILE).like(:application => '(.+)Service')
  #
  def like(search_criteria)
    results = ResultSet.new

    results += _search do |result|
      OpenStruct.new(result) if search_criteria.reject {|criteria,value| result[criteria] =~ /#{value}/ }.empty?
    end

    results
  end
  
  alias_method :matching, :like

  #
  # Search the source for the specific severity
  #
  # @param [String,Symbol] severity the severity of the log messages to search
  #        for within the source
  # @param [Symbol] direction by default search at the severity level, but you
  #        can specify :equal, :equal_and_above, and :equal_and_below
  #
  # @example INFO and more severe
  #   
  #  Indy.search(LOG_FILE).severity('INFO',:equal_and_above)
  #
  # @example Custom Level and Below
  #
  #  Indy.search(LOG_FILE).with([CUSTOM_PATTERN,time,severity,message]).severity(:yellow,:equal_and_below,[:green,:yellow,:orange,:red])
  #  Indy.search(LOG_FILE).with([CUSTOM_PATTERN,time,severity,message]).matching(:severity => '(GREEN|YELLOW)')
  #
  def severity(severity,direction = :equal,scale = SEVERITY)
    severity = severity.to_s.downcase.to_sym

    case direction
    when :equal
      severity = [severity]
    when :equal_and_above
      severity = scale[scale.index(severity)..-1]
    when :equal_and_below
      severity = scale[0..scale.index(severity)]
    end

    ResultSet.new + _search {|result| OpenStruct.new(result) if severity.include?(result[:severity].downcase.to_sym) }

  end


  #
  # Search the specified source and yield to the block the line that was found
  # with the given log pattern
  #
  # This method is suppose to be used internally.
  #
  def _search(source = @source,pattern_array = @pattern,&block)
    regexp, *fields = pattern_array.dup

    results = source.split("\n").collect do |line|
      if /#{regexp}/.match(line)
        values = /#{regexp}/.match(line).captures
        
        values.length.should == fields.length

        hash = Hash[ *fields.zip( values ).flatten ]
        hash[:line] = line
        block_given? ? block.call(hash) : nil
      end
    end

    results.compact
  end

end