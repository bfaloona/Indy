class Indy

  # 
  # A StringIO interface to the underlying log source.
  # 
  class Source

    # log source type. :cmd, :file, or :string
    attr_reader :type

    # log source connection string (cmd, filename or log data)
    attr_reader :connection

    # the StringIO object
    attr_reader :io

    # Exception raised when unable to open source
    class Invalid < Exception; end

    ##
    # Creates a Source object.
    #
    # @param [String, Hash] param The source content String, filepath String, or :cmd => 'command' Hash
    #
    def initialize(param)
      raise Indy::Source::Invalid if param.nil?
      if param.respond_to?(:keys)
        if param[:cmd] # and param[:cmd].length > 0
          set_connection(:cmd, param[:cmd])
        elsif param[:file] # and File.size(param[:file].path) > 0
          set_connection(:file, param[:file])
        elsif param[:string]
          set_connection(:string, param[:string])
        end
      else
        discover_connection(param)
      end
    end

    #
    # Support source being passed in without key indicating type
    #
    def discover_connection(param)
      if param.respond_to?(:read) and param.respond_to?(:rewind)
        set_connection(:file, param)
      elsif param.respond_to?(:to_s) and param.respond_to?(:length)
        set_connection(:string, param)
      else
        raise Indy::Source::Invalid
      end
    end

    #
    # set the source connection type and connection_string
    #
    def set_connection(type, value)
      @type = type
      @connection = value
    end

    #
    # Return a StringIO object to provide access to the underlying log source
    #
    def open(time_boundaries=nil)
      begin
        case @type
        when :cmd
          @io = StringIO.new( exec_command(@connection).read )
          raise "Failed to execute command (#{@connection})" if @io.nil?
        when :file
          @connection.rewind
          @io = StringIO.new(@connection.read)
          raise "Failed to open file: #{@connection}" if @io.nil?
        when :string
          @io = StringIO.new( @connection )
        else
          raise RuntimeError, "Invalid log source type: #{@type.inspect}"
        end
      rescue Exception => e
        raise Indy::Source::Invalid, "Unable to open log source. (#{e.message})"
      end
      load_data
      scope_by_time(time_boundaries) if time_boundaries
      @lines
    end

    #
    # Return entries that meet time criteria
    #
    def scope_by_time(time_boundaries)
      start_time, end_time = time_boundaries
      scope_end = num_lines - 1
      # short circuit the search if possible
      if (time_at(0) > end_time) or (time_at(-1) < start_time)
        @lines = []
        return @lines
      end
      scope_begin = find_first(start_time, 0, scope_end)
      scope_end = find_last(end_time, scope_begin, scope_end)
      @lines = @lines[scope_begin..scope_end]
    end

    #
    # find index of first record to match value
    #
    def find_first(value,start,stop)
      return start if time_at(start) > value
      find(:first,value,start,stop)
    end

    #
    # find index of last record to match value
    #
    def find_last(value,start,stop)
      return stop if time_at(stop) < value
      find(:last,value,start,stop)
    end

    #
    # Find index and time at mid point
    #
    def find_middle(start, stop)
      index = ((stop - start) / 2) + start
      time = time_at(index)
      [index, time]
    end

    #
    # Step forward or backward by one, looking for the boundary of the value
    #
    def find_adjacent(boundary,value,start,stop,mid_index)
      case boundary
      when :first
        (time_at(mid_index,-1) == value) ? find_first(value,start-1,stop) : mid_index
      when :last
        (time_at(mid_index,1) == value) ? find_last(value,start,stop+1) : mid_index
      end
    end

    #
    # Return the time of a log entry index, with an optional offset
    #
    def time_at(index, delta=0)
      Time.parse(@lines[index + delta])
    end

    #
    # Binary search for a time condition
    #
    def find(boundary,value,start,stop)
      return start if start == stop
      mid_index, mid_time = find_middle(start,stop)
      # puts "+ find_#{boundary} (#{value}, #{start}, #{stop}) [mid_index #{mid_index}:#{mid_time}]"
      if mid_time == value
        find_adjacent(boundary,value,start,stop,mid_index)
      elsif mid_time > value
        mid_index -= 1 if mid_index == stop
        find(boundary, value, start, mid_index)
      elsif mid_time < value
        mid_index += 1 if mid_index == start
        find(boundary, value, mid_index, stop)
      end
    end

    #
    # Execute the source's connection string, returning an IO object
    #
    # @param [String] command_string string of command that will return log contents
    #
    def exec_command(command_string)
      io = IO.popen(command_string)
      raise Indy::Source::Invalid, "No data returned from command string execution" if io.eof?
      io
    end

    #
    # the number of lines in the source
    #
    def num_lines
      load_data unless @num_lines
      @num_lines
    end

    #
    # array of log lines from source
    #
    def lines
      load_data unless @lines
      @lines
    end

    #
    # read source data and populate instance variables
    #
    def load_data
      self.open if @io.nil?
      @lines = @io.readlines
      @io.rewind
      @lines.delete_if {|line| line.match(/^\s*$/)}
      @num_lines = @lines.count
    end

  end
end
