class FastSource
  def open(string)
    Struct.new("Line", :id, :msg)
    @data = []
    string.each do |line|
      id, msg = line.split(',')
      @data << Struct::Line.new(id.strip.to_i,  msg.chomp)
    end
    @data
  end

  def set_scope(range)
    @range = range
    @beginning = 0
    @end = @data.size - 1
    @middle = @end / 2
  end

  def scoped_source(range)
    set_scope(range)
    # puts @data.inspect
    find_first(@range.first, @beginning, @end)
  end


  def find_first(id,lower,upper)
    middle = ((upper - lower) / 2) + lower
    # puts "+ find_first(#{id}, #{lower}, #{upper}) [middle #{middle}:#{@data[middle].id}]"
    if @data[middle].id == id
      middle
    elsif @data[middle].id > id
      middle -= 1 if middle == upper
      find_first(id, lower, middle)
    elsif @data[middle].id < id
      middle += 1 if middle == lower
      find_first(id, middle, upper)
    end
  end
end