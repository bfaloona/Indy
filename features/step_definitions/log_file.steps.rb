
Given /^the following log file:$/ do |string|
  @indy = Indy.search(File.open(string, 'r'))
end

Given /^the following log:$/ do |string|
  @indy = Indy.search(string)
end

And /^the custom pattern \(([^\)]+)\):$/ do |fields,pattern|
  @indy = @indy.with({ :entry_regexp => pattern, :entry_fields => fields.split(',').map{|f| f.to_sym} })
end