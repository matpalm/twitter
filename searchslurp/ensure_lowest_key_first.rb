#!/usr/bin/env ruby
STDIN.each do |pair|
  a,b = pair.chomp.split("\t")
  a,b = b,a if b<a
  puts "#{a}\t#{b}"
end
