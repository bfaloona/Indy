
When /^searching the log for the application '([^']+)'$/ do |name|
  @results = Indy.search(@log_source).with(:default).for(:application => name)
end

When /^searching the log for the log severity (\w+)$/ do |severity|
  @results = Indy.search(@log_source).with(:default).for(:severity => severity)
end

When /^searching the log for the log severity (\w+) and lower$/ do |severity|
  @results = Indy.search(@log_source).with(:default).severity(severity,:equal_and_below)
end

When /^searching the log for the log severity (\w+) and higher$/ do |severity|
  @results = Indy.search(@log_source).with(:default).severity(severity,:equal_and_above)
end

When /^searching the log for the exact match of the message "([^"]+)"$/ do |message|
  @results = Indy.search(@log_source).with(:default).for(:message => message)
end

When /^searching the log for matches of the message "([^"]+)"$/ do |message|
  @results = Indy.search(@log_source).with(:default).like(:message => message)
end

When /^searching the log for the time (.+)$/ do |time|
  @results = Indy.search(@log_source).with(:default).for(:time => time)
end

When /^searching the log for:$/ do |fields|
  fields.map_headers! {|header| header.is_a?(Symbol) ? header : header.downcase.gsub(/\s/,'_').to_sym }
  @results = Indy.search(@log_source).for(fields.hashes.first)
end

Then /^I expect the (first|last|\d+(?:st|nd|rd|th)) entry to be:$/ do |position,expected|
  @results[position].line.should == expected
end