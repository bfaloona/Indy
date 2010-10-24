

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
    @pattern = log_pattern
    self
  end

  def search(search_criteria)
    while (criteria = search_criteria.shift)
      puts criteria.first
      puts criteria.last
    end

    ResultSet.new
  end

  def like(search_criteria)
    search(search_criteria)
  end

  alias_method :for, :search



end