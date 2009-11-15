#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'cgi'

url_root = 'http://search.twitter.com/search.json'
url_path = File.exists?('url_path') ? File.read('url_path') : '?q=cheese'
STDERR.puts "initial url_path=#{url_path}"

while true do
	STDERR.puts "\n"*3
	cmd = "curl -s '#{url_root+url_path}'"
	STDERR.puts "*** #{cmd}"
	resp_text = `#{cmd}`	
	begin
		resp = JSON.parse(resp_text)
		STDERR.puts "***** #results = #{resp["results"].size}"

		resp["results"].each do |result|
			time = result['created_at']
			tweet = CGI.unescapeHTML(result['text']).gsub("\n"," ")
			STDERR.puts "#{time} #{tweet}"
		end

		STDOUT.puts resp_text
		STDOUT.flush

=begin
		if resp['next_page']
			STDERR.puts "**** NEXT PAGE"
			url_path = resp['next_page']
			sleep_time = 1
		else
=end
			STDERR.puts "**** REFRESH"
			url_path = resp['refresh_url'] 
			sleep_time = 30
#		end

		url_file = File.open('url_path','w')	
		url_file.puts url_path
		url_file.close

		sleep sleep_time

	rescue Exception => e
		STDERR.puts "OMG! contents #{resp_text}"
		STDERR.puts e.inspect
		url_path = '?q=cheese'
		File.delete 'url_path'
		sleep 60
	end
  
end
