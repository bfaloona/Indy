
class Result

  attr_reader :time, :severity, :application, :message

  def initialize(line, date_time, severity, application, message)
    @line = line
    @time = date_time
    @severity = severity
    @application = application
    @message = message
  end

  def to_s
    @line
  end

end