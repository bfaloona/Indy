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
  def all(&block)
    _iterate_and_compare(:all,nil,&block)
  end

  #
  # Search the source and make an == comparison
  #
  # @param [Hash] search_criteria the field to search for as the key and the
  #        value to compare against the log entries.
  #
  def for(search_criteria,&block)
    _iterate_and_compare(:for, search_criteria,&block)
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
  def like(search_criteria,&block)
    _iterate_and_compare(:like, search_criteria,&block)
  end
  alias_method :matching, :like

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
    entry = last_entries(1)[0]
    starttime = Indy::Time.parse_date(entry[:time],@log_definition.time_format) - span

    within(:time => [starttime,Indy::Time.forever(@log_definition.time_format)])
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
      time = Indy::Time.parse_date(scope_criteria[:time])
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
      time = Indy::Time.parse_date(scope_criteria[:time])
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
  # @param [Hash] scope_criteria the hash containing :time and :span (in minutes) to scope the log.
  #               :span defaults to 5 minutes.
  #
  def around(scope_criteria)
    raise ArgumentError unless scope_criteria.respond_to?(:keys) and scope_criteria[:time]
    time = Indy::Time.parse_date(scope_criteria[:time])
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
      @start_time, @end_time = scope_criteria[:time].collect {|time_string| Indy::Time.parse_date(time_string) }
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
    results = []
    source_lines = (is_time_search ? @source.open([@start_time,@end_time]) : @source.open)
    source_lines.each do |single_line|
      hash = @log_definition.parse_entry(single_line)
      next unless hash
      next unless Indy::Time.inside_time_window?(hash[:time],@start_time,@end_time,@inclusive) if is_time_search
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
      next unless Indy::Time.inside_time_window?(hash[:time],@start_time,@end_time,@inclusive) if is_time_search
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
      @start_time ||= Indy::Time.forever_ago(@log_definition.time_format)
      @end_time ||= Indy::Time.forever(@log_definition.time_format)
    end
    @log_definition.time_field && @start_time && @end_time
  end

  #
  # Helper function called by #for, #like and #all
  #
  # @param [Symbol] type The symbol :for, :like or :all
  #
  # @param [Hash] search_criteria the field to search for as the key and the
  #        value to compare against the log entries.
  #
  def _iterate_and_compare(type,search_criteria,&block)
    results = []
    results += _search do |entry|
      if type == :all || is_match?(type,entry,search_criteria)
        result_struct = @log_definition.create_struct(entry)
        if block_given?
          block.call(result_struct)
        else
          result_struct
        end
      end
    end
    results.compact
  end

  #
  # Evaluates if field => value criteria is an exact match on entry
  #
  # @param [Hash] result The entry_hash
  # @param [Hash] search_criteria The field => value criteria to match
  #
  def is_match?(type, result, search_criteria)
    if type == :for
      search_criteria.reject {|criteria,value| result[criteria] == value }.empty?
    elsif type == :like
      search_criteria.reject {|criteria,value| result[criteria] =~ /#{value}/i }.empty?
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
