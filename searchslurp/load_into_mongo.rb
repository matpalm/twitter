#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'
require 'json'

class Fixnum
  def commaify
    self.to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
  end
end

mongo = Mongo::Connection.new
db = mongo.db 'tweets'
col = db['tweets']

if (col.count==0)
  puts "creating index"
  col.create_index("id")
end

puts "starting collection size #{col.count.commaify}"

existing_records = new_records = 0

STDIN.each do |search_result|
  search_result = JSON::parse(search_result) rescue {}
  next unless search_result.has_key? 'results'
  search_result['results'].each do |tweet|

    id = tweet['id']
    if col.find("id"=>id).count == 1
      existing_records += 1
    else
      col.insert(tweet)
      new_records += 1
    end

=begin
    original_text = tweet['text']   
    text = {}
    text['original'] = original_text
    downcase = original_text.downcase
    text['downcase'] = downcase
    tokens = downcase.split(' ')
    text['tokens'] = tokens
    text['hash_tags'] = tokens.select { |t| t=~/^#/ }
    text['mentions'] = tokens.select { |t| t=~/^@/ }
    tweet['text'] = text
    puts tweet.inspect
=end

  end

end

puts "existing_records=#{existing_records.commaify} new_records=#{new_records.commaify}"
puts "final collection size #{col.count.commaify}"
