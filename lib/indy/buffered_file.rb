class BufferedFile

  attr_reader :buffer_size
  attr_reader :file_size
  attr_reader :file

  def initialize(file)
    @file = file
    begin
      @file_size = File.size(@file.path) if File.exists?(file.path)
    rescue => e
      raise ArgumentError, "Could not open file: #{@file.inspect}.\nThe exception was: #{e.message}"
    end
    self.buffer_size = 128_000
    @buffer = ''
    @buffer_byte_offset = 0
    @buffer_entries = []
  end

  def buffer_size=(size)
    @buffer_size = (@file_size > size ? size : @file_size)
  end

  def [](entry_seek_index)
    return reverse_entry_seek_index(entry_seek_index) if entry_seek_index < 0
    buffer_entry_index = 0
    @buffer_byte_offset = 0
    while entry_seek_index >= buffer_entry_index do
      buffer_entry_index += load_buffer
    end
    entry_index_within_buffer = -(buffer_entry_index - entry_seek_index)
    #puts "entry_index_within_buffer: #{entry_index_within_buffer}"
    #puts "[] return value: #{@buffer_entries[entry_index_within_buffer]}"
    @buffer_entries[entry_index_within_buffer]
  end

  def reverse_entry_seek_index(entry_seek_index)
    buffer_entry_index = 0
    @buffer_byte_offset = @file.size
    while entry_seek_index < buffer_entry_index do
      buffer_entry_index -= load_buffer :reverse
    end
    entry_index_within_buffer = (buffer_entry_index.abs - entry_seek_index.abs)
    #puts "entry_index_within_buffer: #{entry_index_within_buffer}"
    #puts "[] return value: #{@buffer_entries[entry_index_within_buffer]}"
    @buffer_entries[entry_index_within_buffer]
  end

  def load_buffer(reverse=false)
    @file.open.rewind
    #puts "reverse_seek_offset: #{reverse_seek_offset}"
    reverse ? @file.seek(@buffer_byte_offset - @buffer_size) : @file.seek(@buffer_byte_offset)
    @buffer = @file.read(@buffer_size)
    #puts "load_buffer - @buffer: #{@buffer.inspect}"
    buffer_size = @buffer.length
    reverse ? @buffer_byte_offset -= buffer_size : @buffer_byte_offset += buffer_size
    # inform caller if end of file was reached by returning true
    @buffer_entries = split_entries @buffer
    unless @file.eof?
      #puts "!eof"
      # drop trailing entry since it's partial
      last_entry_size = @buffer_entries.last.length
      @buffer_entries = reverse ? @buffer_entries.drop(1) : @buffer_entries[0..-2]
      @buffer_byte_offset -= last_entry_size
    end
    @file.close
    @buffer_entries.size
  end

  def split_entries(data)
    data.split("\n")
  end

  def each_entry
    buffer_entry_index = 0
    @buffer_byte_offset = 0
    at_eof = false
    while !at_eof
      #puts "buffer_entry_index: #{buffer_entry_index}"
      at_eof = load_buffer
      @buffer_entries = split_entries @buffer
      unless at_eof
        #puts "!eof"
        # drop trailing entry since it's partial
        last_entry_size = @buffer_entries.last.length
        @buffer_entries = @buffer_entries[0..-2]
        @buffer_byte_offset -= last_entry_size
      end
      buffer_entry_index += @buffer_entries.size
      #puts "buffer_entry_index: #{buffer_entry_index}"
      #puts "buffer_entries: #{@buffer_entries}"
      @buffer_entries.each do |entry|
        yield entry
      end
    end
  end

end