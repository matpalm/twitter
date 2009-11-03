#!/usr/bin/env ruby
require 'web_cache'
webcache = WebCache.new
STDIN.each do |line|
	id,rating = line.split "\t"
	puts "#{webcache.name id}\t#{rating}"
end
