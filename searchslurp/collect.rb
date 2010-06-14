#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'cgi'

raise 'usage: collect.rb "search term"' unless ARGV.length==1
query = "?q=#{CGI.escape(ARGV.first)}"

url_root = 'http://search.twitter.com/search.json'

url_path = ''
if File.exists?('collect_progress') 
  url_path = File.read('collect_progress')
else
  url_path = "#{query}&rpp=100"
end

STDERR.puts "initial url_path=#{url_path}"

since_id = nil

while true do
  STDERR.puts "\n#{Time.now}"

  request_url = url_root + url_path
  request_url += "&since_id=#{since_id}" if since_id  
  cmd = "curl -s '#{request_url}'"
  STDERR.puts "*** #{cmd}"

  resp_text = `#{cmd}`	
  STDOUT.puts resp_text
  STDOUT.flush

  begin
    resp = JSON.parse(resp_text)

    ids = resp["results"].collect { |result| result['id'].to_i }
    STDERR.puts "ids: [#{ids.min},#{ids.max}]"
    #tweet = CGI.unescapeHTML(result['text']).gsub("\n"," ")    
    
    if resp['next_page']
      STDERR.puts "**** NEXT PAGE"
      url_path = resp['next_page']
      sleep_time = 1
    else      
      url_path = resp['refresh_url'] 
      url_path =~ /since_id=(\d+)/
      since_id = $1
      STDERR.puts "**** REFRESH #{url_path} new since_id=#{since_id}"
      sleep_time = 30
    end

    url_file = File.open('collect_progress','w')	
    url_file.puts url_path
    url_file.close
    
    sleep sleep_time
    
  rescue Exception => e
    STDERR.puts "OMG! contents #{resp_text}"
    STDERR.puts e.inspect
    url_path = query
    sleep 60
  end
  
end
