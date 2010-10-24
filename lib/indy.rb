

class Indy

  def initialize(*args)
    while (arg = args.shift) do
      # deal with parameters
    end
  end

  class << self

    def search(source)
      Indy.new(:source => source)
    end

  end

  def with(log_pattern)
    @patter = log_pattern
    self
  end

  def for(search_criteria)
    
  end
  
end