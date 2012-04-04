class FastSource
  Struct.new("Line", :id, :msg) unless defined?(Struct::Line)
  def open(string)
    @data = []
    string.split("\n").each do |line|
      id, msg = line.split(',')
      @data << Struct::Line.new(id.strip.to_i,  msg.chomp)
    end
    @data
  end


  def scoped_source(range)
    scope_end = @data.size - 1
    scope_begin = find_first(range.first, 0, scope_end)
    scope_end = find_last(range.last, scope_begin, scope_end)
    [scope_begin,scope_end]
  end

  # find index of first record to match id
  def find_first(id,lower,upper)
    find(:first,id,lower,upper)
  end

  # find index of last record to match id
  def find_last(id,lower,upper)
    find(:last,id,lower,upper)
  end

  def find(direction,id,lower,upper)
    return lower if lower == upper
    middle = ((upper - lower) / 2) + lower
    puts "+ find_#{direction} (#{id}, #{lower}, #{upper}) [middle #{middle}:#{@data[middle].id}]"
    if @data[middle].id == id
      case direction
      when :first
        (@data[middle-1].id == id) ? find_first(id,lower-1,upper) : middle
      when :last
        (@data[middle+1].id == id) ? find_last(id,lower,upper+1) : middle
      end
    elsif @data[middle].id > id
      middle -= 1 if ((middle == upper) && (direction == :first))
      find(direction, id, lower, middle)
    elsif @data[middle].id < id
      middle += 1 if ((middle == lower) && (direction == :first))
      find(direction, id, middle, upper)
    end
  end

end
