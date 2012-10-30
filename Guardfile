guard 'rspec', :cli => "--color --format p" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { "spec" }
  watch('spec/helper.rb') { "spec" }
end

guard 'cucumber', :cli => "--color --format progress" do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/step_definitions/.+\.rb$}) { "features" }
  watch(%r{^features/step_definitions/support/.+\.rb$}) { "features" }
  watch(%r{^lib/(.+)\.rb$}) { "features" }
end
