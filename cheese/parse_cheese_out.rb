#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'cgi'

STDIN.each do |resp_text|
	resp = JSON.parse(resp_text)
	resp["results"].each do |result|
		puts CGI.unescapeHTML(result['text']).gsub("\n"," ").downcase		
	end
end

