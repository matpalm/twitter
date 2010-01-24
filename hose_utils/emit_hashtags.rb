#!/usr/bin/env ruby
# for each line of text emit each #hashtag
STDIN.each do |line|
	fields = line.split "\t"
	time,tweet = fields[2],fields[3]
	words = tweet.split
	while not words.empty?
		next_word = words.shift
		puts "#{time}\t#{next_word}" if next_word =~ /^#/
	end
end
