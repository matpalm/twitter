#!/usr/bin/env ruby
# apply an update to existing documents to keep
# them inline with new schema

require 'init_mongo.rb'
require 'date'
require 'time'
require 'sanitise.rb'

sanitiser = Sanitiser.new(:duplicate_spaces_removed)

num_updated = 0

col = connect_to_mongo
col.find('sanitised_text'=>nil).each do |tweet|
  text = tweet['text']
  sanitised_text = sanitiser.sanitise(text)
  tweet['sanitised_text'] = sanitised_text
  col.save(tweet)
  num_updated += 1
end

puts "updated #{num_updated.commaify} of #{col.count.commaify} documents"

