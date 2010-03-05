#!/usr/bin/env ruby

require 'rubygems'
require 'curb'
require 'json'

raise "no APPID env var set!" unless ENV['APPID']

class String

	def lookup_terms_from_yahoo
		begin
			url = "http://search.yahooapis.com/ContentAnalysisService/V1/termExtraction"
			
			params = [
				Curl::PostField.content('context',self),
				Curl::PostField.content('query','cheese'),
				Curl::PostField.content('output','json'),
				Curl::PostField.content('appid',ENV['APPID']) 
			]

			resp = Curl::Easy.http_post(url, *params).body_str

			JSON::parse(resp)['ResultSet']['Result']
		rescue 
			STDERR.puts "#{Time.now} error json parsing response [#{resp}] for #{self}, rate limit exceeded?"
			sleep 60
			retry
		end		
	end

end



