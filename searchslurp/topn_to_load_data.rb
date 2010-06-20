#!/usr/bin/env ruby

records = []

STDIN.each do |line|
  freq,time,pair = line.chomp.split("\t")
  time = time.to_i
  c1,c2 = pair.split("_")
  records[time] ||= []
  records[time] << [c1,c2]
end

# target output
#edges = new Edges[2][];
#edges[0] = new Edge[]{ new Edge("aus","ger"), new Edge("ger","usa") };
#edges[1] = new Edge[]{ new Edge("bra","usa"), new Edge("ger","usa") };
puts "edges = new Edge[#{records.length}][];"
records.each_with_index do |pairs, idx|
  if pairs.nil?
    puts "edges[#{idx}] = new Edge[]{};"
  else 
    edges = pairs.collect { |pair| "new Edge(\"#{pair[0]}\",\"#{pair[1]}\")" }.join(",")
    puts "edges[#{idx}] = new Edge[]{#{edges}};"    
  end
end

