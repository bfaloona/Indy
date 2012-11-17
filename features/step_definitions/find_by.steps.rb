
When /^searching the log for the application '([^']+)'$/ do |name|
  @results = @indy.for(:application => name)
end

When /^searching the log for the log severity (\w+)$/ do |severity|
  @results = @indy.for(:severity => severity)
end

When /^searching the log for the exact match of the message "([^"]+)"$/ do |message|
  @results = @indy.for(:message => message)
end

When /^searching the log for matches of the message "([^"]+)"$/ do |message|
  @results = @indy.like(:message => message)
end

When /^searching the log for:$/ do |fields|
  fields.map_headers! {|header| header.is_a?(Symbol) ? header : header.downcase.gsub(/\s/,'_').to_sym }
  @results = @indy.for(fields.hashes.first)
end

When /^searching the log for entries like:$/ do |fields|
  fields.map_headers! {|header| header.is_a?(Symbol) ? header : header.downcase.gsub(/\s/,'_').to_sym }
  @results = @indy.matching(fields.hashes.first)
end

When /^searching the log for the exact match of custom field ([^"]+)\s*"([^"]+)"$/ do |field,value|
  @results = @indy.for(field.strip.gsub(/\s/,'_').to_sym => value)
end

Then /^I expect the (first|last|\d+(?:st|nd|rd|th)) entry to be:$/ do |position,expected|
  @results[position].raw_entry.should == expected
end

