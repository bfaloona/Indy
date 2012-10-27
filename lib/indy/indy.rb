require 'active_support/core_ext'

class Indy

  # hash with one key (:string, :file, or :cmd) set to the string that defines the log
  attr_accessor :source

  # LogDefinition holds information about the log file
  attr_accessor :log_definition

  #
  # Initialize Indy. Also see class method Indy#search.
  #
  # @example
  #
  #  Indy.new(:source => LOG_CONTENTS_STRING)
  #  Indy.new(:source => {:cmd => LOG_COMMAND_STRING})
  #  Indy.new(:entry_regexp => LOG_REGEX_PATTERN, :entry_fields => [:time,:application,:message], :source => LOG_FILE)
  #  Indy.new(:time_format => '%m-%d-%Y', :entry_regexp => LOG_REGEX_PATTERN, :entry_fields => [:time,:application,:message], :source => LOG_FILE)
  #
  def initialize(args)
    params_hash = args.dup
    @source = @time_format = nil
    if params_hash.keys.include? :source
      self.source = params_hash[:source]
      params_hash.delete :source
    end
    @log_definition = LogDefinition.new(params_hash)
  end

  #
  # Create an Indy::Source object to manage the log source
  #
  # @param [String,Hash] source A filename, or log content as a string. Use a Hash with :cmd key to specify a command string.
  #
  def source=(param)
    @source = Source.new(param)
  end

  class << self

    #
    # Create a new instance of Indy specifying source, or multiple parameters.
    #
    # @param [String,Hash] params To specify @source directly, provide log contents
    #   as a string. Using a hash you can specify source with a :cmd or :file key.
    #   Alternately, a hash with a :source key (among others) can be used to
    #   provide multiple initialization parameters. See Indy#new.
    #
    # @example string source
    #   Indy.search("INFO 2000-09-07 MyApp - Entering APPLICATION.\nINFO 2000-09-07 MyApp - Entering APPLICATION.").all
    #
    # @example command source
    #   Indy.search(:cmd => "cat apache.log").all
    #
    # @example file source
    #   Indy.search(:file => "apache.log").all
    #
    # @example source as well as other parameters
    #   Indy.search(:source => {:cmd => "cat apache.log"}, :entry_regexp => REGEXP, :entry_fields => [:field_one, :field_two], :time_format => MY_TIME_FORMAT).all
    #
    def search(params=nil)
      if params.respond_to?(:keys) && params[:source]
        Indy.new(params)
      else
        Indy.new(:source => params, :entry_regexp => LogFormats::DEFAULT_ENTRY_REGEXP, :entry_fields => LogFormats::DEFAULT_ENTRY_FIELDS, :time_field => :time)
      end
    end

  end

  #
  # Specify the log format to use as the comparison against each entry within
  # the log file that has been specified.
  #
  # @param [Array,LogDefinition] log_definition either a LogDefinition object or an Array with the regular expression as the first element
  #        followed by list of fields (Symbols) in the log entry
  #        to use for comparison against each log entry.
  #
  # @example Log formatted as - HH:MM:SS Message
  #
  #  Indy.search(LOG_FILE).with(/^(\d{2}.\d{2}.\d{2})\s*(.+)$/,:time,:message)
  #
  def with(params=:default)
    @log_definition = LogDefinition.new(params)
    self
  end

  #
  # Return all entries
  #
  def all
    results = ResultSet.new
    results += _search do |entry|
      result_struct = @log_definition.create_struct(entry)
      if block_given?
        yield result_struct
      else
        result_struct
      end
    end
    results
  end

  #
  # Search the source and make an == comparison
  #
  # @param [Hash] search_criteria the field to search for as the key and the
  #        value to compare against the log entries.
  #
  def for(search_criteria)
    results = ResultSet.new
    results += _search do |entry|
      if exact_match?(entry,search_criteria)
        result_struct = @log_definition.create_struct(entry)
        if block_given?
          yield result_struct
        else
          result_struct
        end
      end
    end
    results.compact
  end

  #
  # Search the source and make a regular expression comparison
  #
  # @param [Hash] search_criteria the field to search for as the key and the
  #         value to compare against the log entries.
  #         The value will be treated as a regular expression.
  #
  # @example For all applications that end with Service
  #
  #  Indy.search(LOG_FILE).like(:application => '.+service')
  #
  def like(search_criteria)
    results = ResultSet.new
    results += _search do |result|
      if regexp_match?(result,search_criteria)
        result_struct = @log_definition.create_struct(result)
        if block_given?
          yield result_struct
        else
          result_struct
        end
      end
    end
    results.compact
  end

  alias_method :matching, :like

  #
  # Evaluates if field => value criteria is an exact match on entry
  #
  # @param [Hash] result The entry_hash
  # @param [Hash] search_criteria The field => value criteria to match
  #
  def exact_match?(result, search_criteria)
    search_criteria.reject {|criteria,value| result[criteria] == value }.empty?
  end

  #
  # Evaluates if field => value criteria matches entry when value is treated as a regular expression
  #
  # @param [Hash] result The entry_hash
  # @param [Hash] search_criteria The field => value criteria to match
  #
  def regexp_match?(result, search_criteria)
    search_criteria.reject {|criteria,value| result[criteria] =~ /#{value}/i }.empty?
  end

  #
  # Scopes the eventual search to the last N minutes of entries.
  #
  # @param [Hash] scope_criteria hash describing the amount of time at
  #         the last portion of the source
  #
  # @example For last 10 minutes worth of entries
  #
  #   Indy.search(LOG_FILE).last(:span => 10).all
  #
  def last(scope_criteria)
    raise ArgumentError, "Unsupported parameter to last(): #{scope_criteria.inspect}" unless scope_criteria.respond_to?(:keys) and scope_criteria[:span]
    span = (scope_criteria[:span].to_i * 60).seconds
    starttime = parse_date(last_entries(1)) - span

    within(:time => [starttime, forever])
    self
  end


  #
  # Scopes the eventual search to all entries after to this point.
  #
  # @param [Hash] scope_criteria the field to scope for as the key and the
  #        value to compare against the other log messages
  #
  # @example For all messages after specified date
  #
  #   Indy.search(LOG_FILE).after(:time => time).all
  #
  def after(scope_criteria)
    if scope_criteria[:time]
      time = parse_date(scope_criteria[:time])
      @inclusive = @inclusive || scope_criteria[:inclusive] || nil
      if scope_criteria[:span]
        span = (scope_criteria[:span].to_i * 60).seconds
        within(:time => [time, time + span])
      else
        @start_time = time
      end
    end
    self
  end

  #
  # Removes any existing start and end times from the instance
  # Otherwise consecutive search calls retain time scope state
  #
  def reset_scope
    @inclusive = @start_time = @end_time = nil
  end
    
  #
  # Scopes the eventual search to all entries prior to this point.
  #
  # @param [Hash] scope_criteria the field to scope for as the key and the
  #        value to compare against the other log messages
  #
  # @example For all messages before specified date
  #
  #   Indy.search(LOG_FILE).before(:time => time).all
  #   Indy.search(LOG_FILE).before(:time => time, :span => 10).all
  #
  def before(scope_criteria)
    if scope_criteria[:time]
      time = parse_date(scope_criteria[:time])
      @inclusive = @inclusive || scope_criteria[:inclusive] || nil
      if scope_criteria[:span]
        span = (scope_criteria[:span].to_i * 60).seconds
        within(:time => [time - span, time], :inclusive => scope_criteria[:inclusive])
      else
        @end_time = time
      end
    end
    self
  end

  #
  # Scopes the eventual search to all entries near this point.
  #
  # @param [Hash] scope_criteria the hash containing :time and :span (in minutes) to scope the log
  #
  def around(scope_criteria)
    raise ArgumentError unless scope_criteria.respond_to?(:keys) and scope_criteria[:time]
    time = parse_date(scope_criteria[:time])
    @inclusive = nil
    mid_span = ((scope_criteria[:span].to_i * 60)/2).seconds rescue 300.seconds
    within(:time => [time - mid_span, time + mid_span])
    self
  end


  #
  # Scopes the eventual search to all entries between two times.
  #
  # @param [Hash] scope_criteria the field to scope for as the key and the
  #        value to compare against the other log messages
  #
  # @example For all messages within the specified dates
  #
  #   Indy.search(LOG_FILE).within(:time => [start_time,stop_time]).all
  #
  def within(scope_criteria)
    if scope_criteria[:time]
      @start_time, @end_time = scope_criteria[:time].collect {|str| parse_date(str) }
      @inclusive = @inclusive || scope_criteria[:inclusive] || nil
    end
    self
  end


  private

  #
  # Search the @source and yield to the block the entry that was found
  # with @log_definition
  #
  # This method is supposed to be used internally.
  #
  def _search(&block)
    if @log_definition.multiline
      multiline_search(&block)
    else
      standard_search(&block)
    end
  end

  #
  # Performs #_search for line based entries
  #
  def standard_search(&block)
    is_time_search = use_time_criteria?
    results = ResultSet.new
    source_lines = (is_time_search ? @source.open([@start_time,@end_time]) : @source.open)
    source_lines.each do |single_line|
      hash = @log_definition.parse_entry(single_line)
      next unless hash
      next unless inside_time_window?(hash) if is_time_search
      results << (block.call(hash) if block_given?)
    end
    results.compact
  end

  #
  # Performs #_search for multi-line based entries
  #
  def multiline_search(&block)
    is_time_search = use_time_criteria?
    source_io = StringIO.new( (is_time_search ? @source.open([@start_time,@end_time]) : @source.open ).join("\n") )
    results = source_io.read.scan(Regexp.new(@log_definition.entry_regexp, Regexp::MULTILINE)).collect do |entry|
      hash = @log_definition.parse_entry_captures(entry)
      next unless hash
      next unless inside_time_window?(hash) if is_time_search
      block.call(hash) if block_given?
    end
    results.compact
  end

  #
  #  Return true if start or end time has been set, and a :time field exists
  #
  def use_time_criteria?
    if @start_time || @end_time
      # ensure both boundaries are set
      @start_time = @start_time || forever_ago
      @end_time = @end_time || forever
    end
    @log_definition.time_field && @start_time && @end_time
  end

  #
  # Evaluate if a log entry satisfies the configured time conditions
  #
  # @param [Hash] entry_hash The log entry's hash
  #
  def inside_time_window?( entry_hash )
    time = parse_date( entry_hash )
    return false unless time && entry_hash
    if @inclusive
      true unless time > @end_time or time < @start_time
    else
      true unless time >= @end_time or time <= @start_time
    end
  end

  #
  # Return a valid DateTime object for the log entry string or hash
  #
  # @param [String, Hash] param The log entry string or hash
  #
  def parse_date(param)
    return nil unless @log_definition.time_field
    return param if param.kind_of? Time or param.kind_of? DateTime
    time_string = param.is_a?(Hash) ? param[@log_definition.time_field] : param.to_s
    if @log_definition.time_format
      begin
        # Attempt the appropriate parse method
        DateTime.strptime(time_string, @log_definition.time_format)
      rescue
        # If appropriate, fall back to simple parse method
        DateTime.parse(time_string) rescue nil
      end
    else
      begin
        Time.parse(time_string)
      rescue Exception => e
        raise "Failed to create time object. The error was: #{e.message}"
      end
    end
  end

  #
  # Return a time or datetime object way in the future
  #
  def forever
    @log_definition.time_format ? DateTime.new(4712) : Time.at(0x7FFFFFFF)
  end

  #
  # Return a time or datetime object way in the past
  #
  def forever_ago
    begin
      @log_definition.time_format ? DateTime.new(-4712) : Time.at(-0x7FFFFFFF)
    rescue
      # Windows Ruby Time can't handle dates prior to 1969
      @log_definition.time_format ? DateTime.new(-4712) : Time.at(0)
    end
  end

  #
  # Return an array of Struct::Entry objects for the last N valid entries from the source
  #
  # @param [Fixnum] num the number of entries to retrieve
  #
  def last_entries(num)
    num_entries = 0
    result = []
    source_io = @source.open
    source_io.reverse_each do |entry|
      hash = @log_definition.parse_entry(entry)
      if hash
        num_entries += 1
        result << hash
        break if num_entries >= num
      end
    end
    result.collect{|entry| @log_definition.create_struct(entry)}
  end

end
