class FastSource
  Struct.new("Line", :num, :msg) unless defined?(Struct::Line)
  def open(string)
    @data = []
    string.split("\n").each do |line|
      num, msg = line.split(',')
      @data << Struct::Line.new(num.strip.to_i,  msg.chomp)
    end
    @data
  end

  # return indexes of [begin,end]
  def scoped_source(value_range)
    scope_end = @data.size - 1
    scope_begin = find_first(value_range.first, 0, scope_end)
    scope_end = find_last(value_range.last, scope_begin, scope_end)
    [scope_begin,scope_end]
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
    puts "+ find_#{boundary} (#{value}, #{start}, #{stop}) [mid #{mid}:#{@data[mid].num}]"
    if @data[mid].num == value
      case boundary
      when :first
        (@data[mid-1].num == value) ? find_first(value,start-1,stop) : mid
      when :last
        (@data[mid+1].num == value) ? find_last(value,start,stop+1) : mid
      end
    elsif @data[mid].num > value
      mid -= 1 if ((mid == stop) && (boundary == :first))
      find(boundary, value, start, mid)
    elsif @data[mid].num < value
      mid += 1 if ((mid == start) && (boundary == :first))
      find(boundary, value, mid, stop)
    end
  end

end
