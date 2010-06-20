#!/usr/bin/env ruby
STDIN.each do |line|
  freq,time,pair = line.split("\t")
  c1,c2 = pair.split("_")
  puts "#{freq} #{time} #{c1} #{c2}"
end
