#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'cgi'
require 'mongo_loader.rb'

raise 'usage: collect.rb "search term"' unless ARGV.length==1
query = "?q=#{CGI.escape(ARGV.first)}"

url_root = 'http://search.twitter.com/search.json'
url_path = File.exists?('collect_progress') ? File.read('collect_progress') : "#{query}&rpp=100"

puts "initial url_path=#{url_path}"

since_id = nil

loop do
  puts "\n#{Time.now}"

  # run new query
  request_url = url_root + url_path
  request_url += "&since_id=#{since_id}" if since_id  
  cmd = "curl -s '#{request_url}'"
  puts "*** #{cmd}"
  resp_text = `#{cmd}`	

  begin
    # parse response
    resp = JSON.parse(resp_text)

    # load into mongo
    MongoLoader.new.load(resp)

    # decide what to do next, next page or wait for refresh?
    if resp['next_page']
      puts "**** NEXT PAGE"
      url_path = resp['next_page']
      sleep_time = 1
    else      
      url_path = resp['refresh_url'] 
      url_path =~ /since_id=(\d+)/
      since_id = $1
      puts "**** REFRESH #{url_path} new since_id=#{since_id}"
      sleep_time = 30
    end

    # ensure we are still getting 100 per page
    # this appears to be dropped in refresh urls?
    url_path += "&rpp=100"

    # write progress to file
    url_file = File.open('collect_progress','w')	
    url_file.puts url_path
    url_file.close
    
  rescue Exception => e
    # in case of exception, start again!
    STDERR.puts "OMG! contents #{resp_text}"
    STDERR.puts e.inspect
    url_path = query
    sleep 60

  end

  # yawn
  sleep sleep_time    
  
end
