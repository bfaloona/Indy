
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

When /^searching the log for all entries (\d+) minutes around the time (.+)$/ do |time_span,time|
  @results = @indy.around(:time => time, :span => time_span).for(:all)
end

When /^searching the log for all entries (\d+) minutes after the time (.+)$/ do |time_span,time|
  @results = @indy.after(:time => time, :span => time_span).for(:all)
end

When /^searching the log for all entries (\d+) minutes before the time (.+)$/ do |time_span,time|
  @results = @indy.before(:time => time, :span => time_span).for(:all)
end

