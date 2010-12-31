
When /^searching the log for the time (.+)$/ do |time|
  @results = @indy.for(:time => time)
end

When /^searching the log for all entries after the time (.+)$/ do |time|
  @results = @indy.after(:time => time).for(:all)
end

When /^searching the log for all entries before the time (.+)$/ do |time|
  @results = @indy.before(:time => time).for(:all)
end

When /^searching the log for all entries between the time (.+) and (.+)$/ do |start,stop|
  @results = @indy.within(:time => [start,stop]).for(:all)
end