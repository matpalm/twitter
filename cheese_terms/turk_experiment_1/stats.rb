#!/usr/bin/env ruby
require 'rubygems'
require 'fastercsv'

class_to_score = { 'positive' => 1, 'neutral' => 0, 'negative' => -1 }

csv = FasterCSV.new(File.open(ARGV[0]), :headers=>true)
stats = Hash.new 0
csv.each do |row|
	tweet = row['Input.attribute1']
	clazz = row['Answer.category']
	stats[tweet] += class_to_score[clazz]
#	puts "#{tweet} #{clazz} #{stats[tweet]}"
end

stats.each { |k,v| puts "#{v} #{k}" }
