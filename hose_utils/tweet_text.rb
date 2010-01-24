#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'time'

min,max = nil
num_tweets = 0
STDIN.each do |line|
	begin
		tweet = JSON::parse(line)
		next unless tweet.has_key? 'text'
		text = tweet['text']
		puts text.downcase
	rescue
		STDERR.puts "FAIL on #{line}"
	end
end

