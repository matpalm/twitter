#!/usr/bin/env ruby
require 'init_mongo.rb'
col = connect_to_mongo
col.find().sort('epoch_time','ascending').each do |tweet| 
  puts ['epoch_time','sanitised_text'].collect{|k| tweet[k]}.join("\t")
end

