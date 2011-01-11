
Given /^the following log:$/ do |string|
  @indy = Indy.search(string)
end

And /^the custom pattern \(([^\)]+)\):$/ do |fields,pattern|
  @indy = @indy.with( [ pattern, fields.split(',').map{|f| f.to_sym} ].flatten)
end