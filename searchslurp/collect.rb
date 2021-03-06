#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'cgi'
require 'mongo_loader.rb'
require 'curl'

raise 'usage: collect.rb "search term"' unless ARGV.length==1
query_term = ARGV.first
query = "?q=#{CGI.escape(query_term)}"

url_root = 'http://search.twitter.com/search.json'
url_path = "#{query}&rpp=100"

puts "initial url_path=#{url_path}"

since_id = nil

loader = MongoLoader.new

sleep_time = 1

loop do
  begin
    printf "#{Time.now} "

    # run new query
    request_url = url_root + url_path
    request_url += "&since_id=#{since_id}" if since_id  # sometimes lost on pagination (?)
    request_url += "&rpp=100" # sometimes lost also (?)

    resp_text = Curl::Easy.perform(request_url).body_str
    resp = JSON.parse(resp_text)

    # load into mongo
    loader.load(resp, query_term)

    # decide what to do next, next page or wait for refresh?
    if resp['next_page']
      url_path = resp['next_page']
      sleep_time = 1
    else      
      url_path = resp['refresh_url'] 
      url_path =~ /since_id=(\d+)/
      since_id = $1
      sleep_time = 40
    end

  rescue Exception => e

    # in case of exception, start again!
    STDERR.puts "OMG! contents #{resp_text}"
    STDERR.puts e.inspect
    url_path = query
    since = nil # better to be safe than sorry
    sleep_time = 60

  end

  # yawn
  printf "\n"
  sleep sleep_time    
  
end
