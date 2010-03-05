#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'
require 'json'

mongo = Mongo::Connection.new
mongo.drop_database 'tweets'
db = mongo.db 'tweets'
col = db['tweets']

STDIN.each do |line|
	begin
		col.insert JSON::parse(line)
	rescue Exception => e
		STDERR.puts "line #{line} failed?"
	end	
end


