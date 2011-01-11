
When /^searching the log for the time (.+)$/ do |time|
  @results = @indy.for(:time => time)
end

When /^searching the log for all entries after( and including)? the time (.+)$/ do |inclusive,time|
  @results = @indy.after(:time => time, :inclusive => (inclusive ? true : false)).for(:all)
end

When /^searching the log for all entries before( and including)? the time (.+)$/ do |inclusive,time|
  @results = @indy.before(:time => time, :inclusive => (inclusive ? true : false)).for(:all)
end

When /^searching the log for all entries between( and including)? the times? (.+) and (.+)$/ do |inclusive,start,stop|
  @results = @indy.within(:time => [start,stop], :inclusive => (inclusive ? true : false)).for(:all)
end

When /^searching the log for all entries (\d+) minutes around( and including)? the time (.+)$/ do |time_span,inclusive,time|
  @results = @indy.around(:time => time, :span => time_span, :inclusive => (inclusive ? true : false)).for(:all)
end

When /^searching the log for all entries (\d+) minutes after( and including)? the time (.+)$/ do |time_span,inclusive,time|
  @results = @indy.after(:time => time, :span => time_span, :inclusive => (inclusive ? true : false)).for(:all)
end

When /^searching the log for all entries (\d+) minutes before( and including)? the time (.+)$/ do |time_span,inclusive,time|
  @results = @indy.before(:time => time, :span => time_span, :inclusive => (inclusive ? true : false)).for(:all)
end

