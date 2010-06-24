#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'mongo'
require 'curl'

raise "usage: get_words_for_friends.rb USER INFOCHIMPS_APIKEY" unless ARGV.length==2
USER, APIKEY = ARGV

class String
  def fetch_as_json
    puts "fetching for #{self}"
    JSON::parse(Curl::Easy.perform(self).body_str)
  end
end

def fetch_and_save id

  already_collected = @users.find("id"=>id).count > 0
  return if already_collected

  user_info = "http://api.twitter.com/1/users/show.json?id=#{id}".fetch_as_json

  word_bag = "http://api.infochimps.com/soc/net/tw/wordbag.json?user_id=#{id}&apikey=#{APIKEY}".fetch_as_json
  user_info['word_bag'] = word_bag

  @users.insert user_info

rescue Exception => e
  STDERR.puts "fail!!! #{id}"
  STDERR.puts e.backtrace
  sleep 5
  retry
end

mongo = Mongo::Connection.new('localhost','12300')
db = mongo.db 'wordbag'
@users = db['users']

friends = "http://api.twitter.com/1/friends/ids.json?id=#{USER}".fetch_as_json
friends.each do |id| 
  fetch_and_save id
end

