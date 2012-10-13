class LogDefinition
  attr_accessor :entry_regexp, :entry_fields, :time_format, :time_field, :multiline

  def initialize args
    params_hash = args.dup
    # support 0.3.4 params
    if params_hash.keys.include? :log_format
      params_hash[:entry_regexp] = args[:log_format][0]
      params_hash[:entry_fields] = args[:log_format][1..-1]
      params_hash.delete :log_format
    end
    while (param = params_hash.shift) do
      send("#{param.first}=",param.last)
    end
    if !@time_field && entry_fields.include?(:time)
      @time_field = :time
    end
  end

end