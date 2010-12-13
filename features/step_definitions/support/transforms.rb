
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