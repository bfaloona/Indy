class Indy

  class Source
    def initialize

    end

    def start_time

    end
    
    def end_time
      
    end
    
  end


  #
  # Sets the source for the Indy instance.
  #
  # @param [String,Hash] source A filename, or log content as a string. Use a Hash with :cmd key to specify a command string.
  #
  # @example
  #
  #   source("apache.log")
  #   source(:cmd => "cat apache.log")
  #   source("INFO 2000-09-07 MyApp - Entering APPLICATION.\nINFO 2000-09-07 MyApp - Entering APPLICATION.")
  #
  def source=(param)

    raise Indy::InvalidSource if param.nil?

    cmd = param[:cmd] rescue nil
    @source[:cmd] = param[:cmd] if cmd

    unless cmd
      File.exist?(param) ? @source[:file] = param : @source[:string] = param
    end

    raise Indy::InvalidSource unless @source.values.reject {|value| value.kind_of? String }.empty?

  end

  #
  # throw away large portions of the source that don't match the time criteria
  #
  def scope_by_time(source_io)
    return StringIO.new('') if @start_time > source_end_time
    return StringIO.new('') if @end_time < source_start_time

    source_io
  end


  #
  # Return a Struct::Line for the last valid entry from the source
  #
  def last_entry
    last_entries(1)
  end

  #
  # Return an array of Struct::Line entries for the last N valid entries from the source
  #
  # @param [Fixnum] num the number of rows to retrieve
  #
  def last_entries(num)

    num_entries = 0
    result = []

    source_io = open_source
    source_io.reverse_each do |line|

      hash = parse_line(line)

      set_time(hash) if @time_field

      if hash
        num_entries += 1
        result << hash
        break if num_entries >= num
      end
    end

    warn "No matching lines found in source: #{source_io.class}" if result.empty?

    source_io.close if @source[:file] || @source[:cmd]

    num == 1 ? create_struct(result.first) : result.collect{|e| create_struct(e)}
  end

  #
  # Return a log io object
  #
  def open_source(time_search=nil)
    begin

      case @source.keys.first # and only
      when :cmd
        source_io = exec_command(@source[:cmd])
        raise "Failed to execute command (#{@source[:cmd]})" if source_io.nil?

      when :file
        source_io = File.open(@source[:file], 'r')
        raise "Filed to open file: #{@source[:file]}" if source_io.nil?

      when :string
        source_io = StringIO.new( @source[:string] )

      else
        raise "Unsupported log source: #{@source.inspect}"
      end

    rescue Exception => e
      raise "Unable to open log source. (#{e.message})"
    end

    #scope_by_time(source_io) if time_search

    source_io
  end

end