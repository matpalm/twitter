#!/usr/bin/env ruby
# apply an update to existing documents to keep
# them inline with new schema

require 'init_mongo.rb'
require 'date'
require 'time'

def for_each_in clause
  col = connect_to_mongo
  num_updated = 0
  col.find(clause).each do |tweet|
    yield tweet
    col.save(tweet)
    num_updated += 1
  end
  puts "updated #{num_updated.commaify} of #{col.count.commaify} documents"
end

for_each_in({'found_with_query'=>nil}) do |tweet|
  tweet['found_with_query'] = '#worldcup'
end

=begin
require 'sanitise.rb'
sanitiser = Sanitiser.new(:duplicate_spaces_removed)
for_each_in({'sanitised_text'=>nil}) do |tweet|
  text = tweet['text']
  sanitised_text = sanitiser.sanitise(text)
  tweet['sanitised_text'] = sanitised_text
end
=end



