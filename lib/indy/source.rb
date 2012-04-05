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
        set_connection(:cmd, param[:cmd]) if param[:cmd]
        set_connection(:file, param[:file]) if ( param[:file] and File.size(param[:file].path) > 0 )
        set_connection(:string, param[:string]) if param[:string]
      elsif param.respond_to?(:read) and param.respond_to?(:rewind)
        set_connection(:file, param)
      elsif param.respond_to?(:to_s) and param.respond_to?(:length)
        # fall back to source being the string passed in
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
    def open(time_boundaries)
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
   
    def scope_by_time(time_boundaries)
      start_time, end_time = time_boundaries
      scope_end = num_lines - 1
      scope_begin = find_first(start_time, 0, scope_end)
      scope_end = find_last(end_time, scope_begin, scope_end)
      @lines = @lines[scope_begin..scope_end]
    end
         
    # find index of first record to match value
    def find_first(value,start,stop)
      find(:first,value,start,stop)
    end

    # find index of last record to match value
    def find_last(value,start,stop)
      find(:last,value,start,stop)
    end

    def find(boundary,value,start,stop)
      return start if start == stop
      mid = ((stop - start) / 2) + start
      mid_time = Time.parse(@lines[mid])
      puts "+ find_#{boundary} (#{value}, #{start}, #{stop}) [mid #{mid}:#{mid_time}]"
      if mid_time == value
        case boundary
        when :first
          (Time.parse(@lines[mid-1]) == value) ? find_first(value,start-1,stop) : mid
        when :last
          (Time.parse(@lines[mid+1]) == value) ? find_last(value,start,stop+1) : mid
        end
      elsif mid_time > value
        mid -= 1 if ((mid == stop) && (boundary == :first))
        find(boundary, value, start, mid)
      elsif mid_time < value
        mid += 1 if ((mid == start) && (boundary == :first))
        find(boundary, value, mid, stop)
      end
    end


    #
    # Execute the source's connection string, returning an IO object
    #
    # @param [String] command_string string of command that will return log contents
    #
    def exec_command(command_string)
      begin
        io = IO.popen(command_string)
        return nil if io.eof?
      rescue
        nil
      end
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
    # TODO: hmmm... not called when Source#open is called directly, but #load_data would call open again. :(
    #
    def load_data
      self.open if @io.nil?
      @lines = @io.readlines
      @io.rewind
      @num_lines = @lines.count
      @num_bytes = @io.bytes
    end

    def num_bytes
      @num_bytes
    end

    def current_line

    end

  end
end
