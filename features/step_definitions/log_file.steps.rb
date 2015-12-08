
Given /^the following log file object:$/ do |string|
  @indy = Indy.search(File.open(string, 'r'))
end

Given /^the following log file path:$/ do |string|
  @indy = Indy.search(:file => string)
end

Given /^the following log:$/ do |string|
  @indy = Indy.search(string)
end

Given /^the following log, using (COMMON_LOG_FORMAT|COMBINED_LOG_FORMAT):$/ do |log_format, string|
  @indy = Indy.search(string).with("Indy::#{log_format}")
end

And /^the custom pattern \(([^\)]+)\):$/ do |fields,pattern|
  @indy = @indy.with({ :entry_regexp => pattern, :entry_fields => fields.split(',').map{|f| f.to_sym} })
end
