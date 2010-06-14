#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'date'
require 'cgi'
require 'pp'

STDIN.each do |resp_text|
	begin
		tweet = JSON.parse(resp_text)
		next if tweet.has_key? 'delete'
		puts tweet["user"]["id"]
	rescue
		puts "FAIL #{resp_text}"
	end
end


