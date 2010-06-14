#!/usr/bin/env ruby
# apply an update to existing documents to keep
# them inline with new schema

require 'init_mongo.rb'
require 'date'
require 'time'

num_updated = 0

col = connect_to_mongo
col.find("epoch_time"=>nil).each do |tweet|
  created_at_str = tweet['created_at']
  epoch_time = Time.parse(created_at_str).to_i
  tweet['epoch_time'] = epoch_time
  col.save(tweet)
  num_updated += 1
end

puts "updated #{num_updated.commaify} of #{col.count.commaify} documents"

