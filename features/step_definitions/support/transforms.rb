
Transform /^no$/ do |no|
  0
end

Transform /^(\d+)$/ do |number|
  number.to_i
end

Then /^I expect to have found (no|\d+) log entr(?:y|ies)$/ do |count|
  expect(@results.size).to eq(count)
end

Transform /^first$/ do |order|
  0
end
Transform /^last$/ do |order|
  -1
end

# When searching the log for all entries after and including the time 2000-09-07 14:07:44
Transform /^ and including$/ do |inclusive|
  true
end