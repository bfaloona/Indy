
require 'scanf'

f = File.open('spec/multiline.log')

first_capture_regexp = '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'

full_regexp = "^(#{first_capture_regexp})\\s+([A-Z]+)\\s+(.+?)(?=^#{first_capture_regexp}|\\z)"
  
  f.read.scan(/#{full_regexp}/m) do |entry|
  puts "Entry::::\n#{entry}"
end

