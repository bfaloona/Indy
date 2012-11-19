class Indy

  class Search

    attr_accessor :source
    attr_accessor :log_definition

    attr_accessor :start_time, :end_time, :inclusive

    def initialize(params_hash)
      while (param = params_hash.shift) do
        send("#{param.first}=",param.last)
      end
    end

    #
    # Helper function called by Indy#for, Indy#like and Indy#all
    #
    # @param [Symbol] type The symbol :for, :like or :all
    #
    # @param [Hash] search_criteria the field to search for as the key and the
    #        value to compare against the log entries.
    #
    def iterate_and_compare(type,search_criteria,&block)
      results = []
      results += search do |entry|
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
    # Search the @source and yield to the block the entry that was found
    # with @log_definition
    #
    # This method is supposed to be used internally.
    #
    def search(&block)
      if @log_definition.multiline
        multiline_search(&block)
      else
        standard_search(&block)
      end
    end

    #
    # Performs #search for line based entries
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
    # Performs #search for multi-line based entries
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
      @start_time && @end_time
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
    # Parse hash to set @start_time, @end_time and @inclusive
    #
    def time_scope(params_hash)
      if params_hash[:time]
        time_scope_from_direction(params_hash[:direction], params_hash[:span], params_hash[:time])
      else
        @start_time = Indy::Time.parse_date(params_hash[:start_time]) if params_hash[:start_time]
        @end_time = Indy::Time.parse_date(params_hash[:end_time]) if params_hash[:end_time]
      end
      @inclusive = params_hash[:inclusive]
    end

    #
    # Parse direction, span, and time to set @start_time and @end_time
    #
    def time_scope_from_direction(direction, span, time)
       time = Indy::Time.parse_date(time)
      span = (span.to_i * 60).seconds if span
      if direction == :before
        @end_time = time
        @start_time = time - span if span
      elsif direction == :after
        @start_time = time
        @end_time = time + span if span
      end
    end

    #
    # Clear time scope settings
    #
    def reset_scope
      @inclusive = @start_time = @end_time = nil
    end

  end

end