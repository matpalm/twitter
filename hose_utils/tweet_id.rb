#!/usr/bin/env ruby
require 'json'
STDIN.each do |line|
	begin
		tweet = JSON::parse(line)
		if tweet.has_key? 'id'
			puts tweet['id']
		elsif tweet.has_key? 'delete'
			puts tweet['delete']['status']['id']
		end
	rescue
		STDERR.puts "FAIL on #{line}"
	end
end
