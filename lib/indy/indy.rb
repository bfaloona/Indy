require 'ostruct'
require 'active_support'

module Indy

  VERSION = "0.1.0"

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
      #   Indy.search(:cmd, "cat apache.log").for(:severity => "INFO")
      #
      def search(*source)
        Indy.new(:source => source, :pattern => [DEFAULT_LOG_PATTERN,DEFAULT_LOG_FIELDS].flatten)
      end

    end

    def source=(specified_source)
      cmd = (specified_source.first == :cmd) rescue nil
      specified_source = specified_source.last if specified_source.kind_of? Array

      if cmd
        possible_source = try_as_command(specified_source)
      else        
        possible_source = try_as_file(specified_source) unless possible_source
        possible_source = StringIO.new(specified_source.to_s) unless possible_source
      end

      @source = possible_source
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
    # given a set of log entries, determine the time boundaries and span
    #
    def time_boundaries(log_entries)
      begin_time = log_entries.first._time
      end_time = log_entries.last._time
      time_span = end_time - begin_time
      [begin_time, end_time, time_span]
    end

    #
    # first( :half, :time )
    # first( "5 minutes" )
    #
    def first(portion, method=nil, do_last=false)
      last(portion, method, false)
    end
    
    #
    # last(:half, :time)
    # last( "2 minutes" )
    #
    def last(portion, method=nil, do_last=true)

      if portion.kind_of? Symbol and method.kind_of? Symbol
        raise "unsuported" unless portion == :half
        raise "unsuported" unless method == :time

        return ResultSet.new if _time_field == 0

        all_results = ResultSet.new + _search {|result| OpenStruct.new(result) }
        begin_time, end_time, time_span = time_boundaries(all_results)
        mid_time = begin_time + (time_span / 2)

        all_results.select do |entry|
          do_last ? entry._time > mid_time : entry._time < mid_time
        end

      elsif portion.kind_of? String and !method

        all_results = ResultSet.new + _search {|result| OpenStruct.new(result) }
        begin_time, end_time, time_span = time_boundaries(all_results)
        quantity, units = portion.match(/(\d+) (.+)/).captures
        raise "unsupported" unless units.match(/minutes?/)
        portion_seconds = quantity.to_i.send(units.intern)
        boundry_time = do_last ? end_time - portion_seconds : begin_time + portion_seconds
        all_results.select do |entry|
          do_last ? entry._time > boundry_time : entry._time < boundry_time
        end
      end

    end

    #
    # Search the specified source and yield to the block the line that was found
    # with the given log pattern
    #
    # This method is suppose to be used internally.
    # @param [IO] source is a Ruby IO object
    #
    def _search(source = @source,pattern_array = @pattern,&block)
      regexp, *fields = pattern_array.dup

      results = source.each.collect do |line|
        if /#{regexp}/.match(line)
          values = /#{regexp}/.match(line).captures

          raise "Field mismatch between log pattern and log data. The data is: '#{values.join(':::')}'" unless values.length == fields.length

          hash = Hash[ *fields.zip( values ).flatten ]
          hash[:line] = line.strip
          hash[:_time] = _parse_date( hash )
          block_given? ? block.call(hash) : nil
        end
      end

      results.compact
    end

    #
    # Return the date/time field
    #
    def _time_field
      @time_field ||= ( @pattern.include?(:time) ? :time : ( @pattern.include?(:date) ? :date : 0 ) )
    end
    
    #
    # Return a valid DateTime object for the log line
    #
    def _parse_date(line_hash)
      return nil if _time_field == 0

      begin        
        DateTime.parse(line_hash[ _time_field ])
      rescue ArgumentError
        @time_field = 0
        return nil
      end

    end

    #
    # Try opening the string as a command string, returning an IO object
    #
    def try_as_command(command_string)

      begin
        io = IO.popen(command_string)
        return nil if io.eof?
      rescue
        nil
      end
      io
    end

    #
    # Try opening the string as a file, returning an File IO Object
    #
    def try_as_file(filename)

      begin
        File.open(filename)
      rescue
        nil
      end

    end

  end

end