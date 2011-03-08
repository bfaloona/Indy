class Indy

  # 
  # A StringIO interface to the underlying log source.
  # 
  class Source

    # log source type. :cmd, :file, or :string
    attr_reader :type

    # log source connection string (cmd, filename or log data)
    attr_reader :connection_string

    # the SriingIO object
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

      if param.kind_of?(Enumerable) && param[:cmd]
        set_connection(:cmd, param[:cmd])
      else
  
        raise Indy::Source::Invalid unless param.kind_of? String

        if File.exist?(param)
          set_connection(:file, param)
        else
          # fall back to source being the string passed in
          set_connection(:string, param)
        end
      end

      raise Indy::Source::Invalid unless @connection_string.kind_of? String
    end

    #
    # set the source connection type and connection_string
    #
    def set_connection(type, string)
      @type = type
      @connection_string = string
    end

    #
    # Return a StringIO object to provide access to the underlying log source
    #
    def open(time_search=nil)
      begin

        case @type
        when :cmd
          @io = StringIO.new( exec_command(@connection_string).read )
          raise "Failed to execute command (#{@connection_string})" if @io.nil?

        when :file
          File.open(@connection_string, 'r') do |file|
            @io = StringIO.new(file.read)
          end
          raise "Failed to open file: #{@connection_string}" if @io.nil?

        when :string
          @io = StringIO.new( @connection_string )

        else
          raise RuntimeError, "Invalid log source type: #{@type.inspect}"
        end

      rescue Exception => e
        raise "Unable to open log source. (#{e.message})"
      end

      # scope_by_time(source_io) if time_search

      @io
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
    def load_data
      self.open
      @lines = @io.readlines
      @io.rewind
      @num_lines = @lines.count
    end

    # def start_time
    # end

    # def end_time
    # end

    #
    # trim data to match scope of start_time and end_time
    #
    def scope_by_time(source_io)
      return StringIO.new('') if @start_time > source_end_time
      return StringIO.new('') if @end_time < source_start_time

      source_io
    end

  end
end