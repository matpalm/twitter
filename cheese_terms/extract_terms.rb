#!/usr/bin/env ruby

require 'rubygems'
require 'curb'
require 'json'

raise "no APPID env var set!" unless ENV['APPID']

class String

	def lookup_terms_from_yahoo
		begin
			url = "http://search.yahooapis.com/ContentAnalysisService/V1/termExtraction"
			
			text = Curl::PostField.content('context',self)
			query = Curl::PostField.content('query','cheese')
			output = Curl::PostField.content('output','json')
			api_key = Curl::PostField.content('appid',ENV['APPID'])

			resp = Curl::Easy.http_post(url, text, query, output, api_key).body_str

			JSON::parse(resp)['ResultSet']['Result']
		rescue 
			STDERR.puts "error json parsing response #{resp}, rate limit exceeded?"
			sleep 60
			retry
		end		
	end

end



