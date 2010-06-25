#!/usr/bin/env ruby
puts "graph {"
puts "node [ fontname=Arial, fontsize=15];"
STDIN.each do |line|
  sim,u1,u2 = line.chomp.split("\t")
  puts %{"#{u1}" -- "#{u2}"}
end
puts "}"
