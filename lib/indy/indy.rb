class Indy

  # search object
  attr_accessor :search

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
    params = args.dup
    raise ArgumentError, "Source parameter not specified" unless (params.respond_to?(:keys) && params.keys.include?(:source))
    source_param = params[:source]
    params.delete :source
    @search = Search.new()
    @search.source = Source.new( source_param, LogDefinition.new(params) )
  end

  class << self

    #
    # Create a new instance of Indy specifying source, or multiple parameters.
    #
    # @param [String,Hash] params To specify a source directly, provide log contents
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
    #   Indy.search(:file => "/logs/apache.log").all
    #
    # @example source as well as other parameters
    #   Indy.search(:source => {:cmd => "cat apache.log"}, :entry_regexp => REGEXP, :entry_fields => [:field_one, :field_two], :time_format => MY_TIME_FORMAT).all
    #
    def search(params=nil)
      if params.respond_to?(:keys) && params[:source]
        Indy.new(params)
      else
        Indy.new(:source => params, :entry_regexp => LogFormats::DEFAULT_ENTRY_REGEXP, :entry_fields => LogFormats::DEFAULT_ENTRY_FIELDS)
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
    if params.kind_of?(String) && params.match(/^Indy::/)
      params = params.constantize
    end
    @search.source.log_definition = LogDefinition.new(params)
    self
  end

  #
  # Return all entries
  #
  def all(&block)
    @search.iterate_and_compare(:all,nil,&block)
  end

  #
  # Search the source and make an == comparison
  #
  # @param [Hash] search_criteria the field to search for as the key and the
  #        value to compare against the log entries.
  #
  def for(search_criteria,&block)
    @search.iterate_and_compare(:for,search_criteria,&block)
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
    @search.iterate_and_compare(:like,search_criteria,&block)
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
    start_time = Indy::Time.parse_date(entry[:time], @search.source.log_definition.time_format) - span
    within(:start_time => start_time, :end_time => Indy::Time.forever(@search.source.log_definition.time_format))
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
    params = scope_criteria.merge({:direction => :after})
    within(params)
    self
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
    params = scope_criteria.merge({:direction => :before})
    within(params)
  end

  #
  # Scopes the eventual search to all entries near this point.
  #
  # @param [Hash] scope_criteria the hash containing :time and :span (in minutes) to scope the log.
  #               :span defaults to 5 minutes.
  #
  def around(scope_criteria)
    raise ArgumentError unless scope_criteria.respond_to?(:keys) and scope_criteria[:time]
    time = Indy::Time.parse_date(scope_criteria[:time], @search.source.log_definition.time_format)
    mid_span = ((scope_criteria[:span].to_i * 60)/2).seconds rescue 300.seconds
    within(:start_time => time - mid_span, :end_time => time + mid_span, :inclusive => nil)
    self
  end


  #
  # Scopes the eventual search to all entries between two times.
  #
  # @param [Hash] params the :start_time, :end_time and :inclusive key/value pairs
  #
  # @example For all messages within the specified dates
  #
  #   Indy.search(LOG_FILE).within(:start_time => start_time, :end_time => end_time, :inclusive => true).all
  #
  def within(params)
    @search.time_scope(params)
    self
  end

  #
  # Removes any existing start and end times from the instance
  # Otherwise consecutive search calls retain time scope state
  #
  def reset_scope
    @search.reset_scope
  end


  private

  #
  # Return an array of Struct::Entry objects for the last N valid entries from the source
  #
  # @param [Fixnum] num the number of entries to retrieve
  #
  def last_entries(num)
    num_entries = 0
    result = []
    source_io = @search.source.open
    source_io.reverse_each do |entry|
      hash = @search.source.log_definition.parse_entry(entry)
      if hash
        num_entries += 1
        result << hash
        break if num_entries >= num
      end
    end
    result.collect{|entry| @search.source.log_definition.create_struct(entry)}
  end

end
