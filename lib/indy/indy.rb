

class Indy

  attr_accessor :source, :pattern

  DATE_TIME = "\\d{4}.\\d{2}.\\d{2}\s+\\d{2}.\\d{2}.\\d{2}" #"%Y-%m-%d %H:%M:%S"
  SEVERITY = "(?:TRACE|DEBUG|INFO|WARN|ERROR|FATAL)"
  APPLICATION = "\\w+"
  MESSAGE = ".+"
  DEFAULT_LOG_PATTERN = "^(#{DATE_TIME})\\s+(#{SEVERITY})\\s+(#{APPLICATION})\\s+-\\s+(#{MESSAGE})$"
 
  def initialize(args)
    @source = @pattern = nil

    while (arg = args.shift) do
      send("#{arg.first}=",arg.last)
    end
  end

  class << self

    def search(source)
      Indy.new(:source => source)
    end

  end

  def with(log_pattern)
    @pattern = log_pattern == :default ? DEFAULT_LOG_PATTERN : log_pattern
    self
  end

  def search(search_criteria)
    results = ResultSet.new

    while (criteria = search_criteria.shift)
      results += _search(source,criteria.first,criteria.last)
    end

    results
  end

  def like(search_criteria)
    search(search_criteria)
  end

  alias_method :for, :search

  def _search(source,term,value)
    source.split("\n").collect do |line|
      if %r{#{DEFAULT_LOG_PATTERN}}.match(line)
        result = Result.new(line,$1, $2, $3, $4) #date_time, severity, application, message
        result.send(term) == value ? result : nil
      end
    end
  end


end