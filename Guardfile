guard 'rspec', :cli => "--color --format d" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { "spec" }
  watch('spec/helper.rb') { "spec" }
end
