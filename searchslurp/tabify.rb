#!/usr/bin/env ruby
STDIN.each do |line| 
  puts line.chomp.strip.split.join("\t") 
end
