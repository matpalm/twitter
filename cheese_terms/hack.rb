#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'
require 'json'

mongo = Mongo::Connection.new
db = mongo.db 'tweets'
col = db['tweets']

class String
	def sanitise
		self.gsub('"',' ').gsub(/\n/,' ').gsub(/\s+/,' ')
	end
end

puts "attribute1,attribute2"
col.find({'has_tweet_terms' => true}).each do |tweet|	
	terms = tweet['text_terms']
	next unless terms.size == 1
	text = tweet['text'].sanitise
	topic = terms.first.sanitise
	puts [text,topic].collect{|t| "\"#{t}\"" }.join(',')
end

