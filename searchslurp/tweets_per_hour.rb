#!/usr/bin/env ruby
require 'set'
require 'time'

hour_offset = nil

STDIN.each do |time_and_tweet|
  time = time_and_tweet.split("\t").first
  seconds = time.to_i
  hours = seconds / 60 / 60
  hour_offset ||= hours
  hours -= hour_offset
  puts hours
end





