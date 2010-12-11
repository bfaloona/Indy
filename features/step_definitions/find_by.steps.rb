
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

Transform /^no$/ do |no|
  0
end

Transform /^(\d+)$/ do |number|
  number.to_i
end

Then /^I expect to have found (no|\d+) log entr(?:y|ies)$/ do |count|
  @results.size.should == count
end

Transform /^first$/ do |order|
  0
end
Transform /^last$/ do |order|
  -1
end

Transform /^(\d+)(?:st|nd|rd|th)$/ do |order|
  order.to_i - 1
end

Then /^I expect the (first|last|\d+(?:st|nd|rd|th)) entry to be:$/ do |position,expected|
  @results[position].line.should == expected
end