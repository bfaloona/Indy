class Indy

  class LogDefinition

    attr_accessor :entry_regexp, :entry_fields, :time_format, :multiline

    def initialize(args)
      case args
      when :default, {}, nil
        params_hash = set_defaults
      when Array, Hash
        params_hash = parse_enumerable_params(args)
      end
      while (param = params_hash.shift) do
        send("#{param.first}=",param.last)
      end
      raise ArgumentError, "Values for entry_regexp and/or entry_fields were not supplied" unless (@entry_fields && @entry_regexp)
      define_struct
    end

    def set_defaults
      params_hash = {}
      params_hash[:entry_regexp] = Indy::LogFormats::DEFAULT_ENTRY_REGEXP
      params_hash[:entry_fields] = Indy::LogFormats::DEFAULT_ENTRY_FIELDS
      params_hash
    end

    def parse_enumerable_params(args)
      params_hash = {}
      params_hash.merge!(args)
      if args.keys.include? :log_format
        # support 0.3.4 params
        params_hash[:entry_regexp] = args[:log_format][0]
        params_hash[:entry_fields] = args[:log_format][1..-1]
        params_hash.delete :log_format
      end
      params_hash
    end

    #
    # Return a Struct::Entry object from a hash of values from a log entry
    #
    # @param [Hash] entry_hash a hash of :field_name => value pairs for one log entry
    #
    def create_struct( entry_hash )
      values = entry_hash.keys.sort_by{|entry|entry.to_s}.collect {|key| entry_hash[key]}
      result = Struct::Entry.new( *values )
      result
    end

    #
    # Define Struct::Entry with the fields from @log_definition. Ignore warnings.
    #
    def define_struct
      fields = (@entry_fields + [:raw_entry]).sort_by{|key|key.to_s}
      verbose = $VERBOSE
      $VERBOSE = nil
      Struct.new( "Entry", *fields )
      $VERBOSE = verbose
    end

    #
    # Convert log entry into hash
    #
    def entry_hash(values)
      assert_valid_field_list(values) unless @field_list_is_valid # just do it once
      raw_entry = values.shift
      hash = Hash[ *@entry_fields.zip( values ).flatten ]
      hash[:raw_entry] = raw_entry.strip
      hash
    end


    #
    # Return a hash of field=>value pairs for the log entry
    #
    # @param [String] raw_entry The raw log entry
    #
    def parse_entry(raw_entry)
      match_data = /#{@entry_regexp}/.match(raw_entry)
      return nil unless match_data
      values = match_data.captures
      entry_hash([raw_entry, values].flatten)
    end

    #
    # Return a hash of field=>value pairs for the array of captured values from a log entry
    #
    # @param [Array] capture_array The array of values captured by the @log_definition.entry_regexp
    #
    def parse_entry_captures( capture_array )
      entire_entry = capture_array.shift
      values = capture_array
      entry_hash([entire_entry, values].flatten)
    end

    #
    # Ensure number of fields is expected
    #
    def assert_valid_field_list(values)
      if values.length == @entry_fields.length + 1 # values also includes raw_entry
        @field_list_is_valid = true
      else
        raise ArgumentError, "Field mismatch between log pattern and log data. The data is: '#{values.join(':::')}'"
      end
    end

  end

end