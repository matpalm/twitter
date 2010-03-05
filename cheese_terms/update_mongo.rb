#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'
require 'json'
require 'extract_terms'
require 'sanitise'

mongo = Mongo::Connection.new
db = mongo.db 'tweets'
col = db['tweets']

while true do
	tweet = col.find_one('text_terms' => nil)
	break unless tweet

	tweet['text_terms'] = tweet['text'].sanitise.lookup_terms_from_yahoo

	col.save tweet

	puts "extracted for tweet_id=#{tweet['id']} from [#{tweet['text']}] the terms #{tweet['text_terms'].inspect}"

end

