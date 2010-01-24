#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'time'

min,max = nil
num_tweets = 0
STDIN.each do |line|
	begin
		tweet = JSON::parse(line)
		puts tweet['text']
=begin
		if tweet.has_key? 'id'
			id = tweet['id']
			uid = tweet['user']['id']
			timestamp = Time.parse(tweet['created_at']).to_i
			text = tweet['text'].gsub("\t",' ').gsub("\n",' ').gsub(/\s+/,' ')
			puts [id,uid,timestamp,text].join "\t"
		elsif tweet.has_key? 'delete'
#			puts tweet['delete']['status']['id']
		end
=end
	rescue
		STDERR.puts "FAIL on #{line}"
	end
end

