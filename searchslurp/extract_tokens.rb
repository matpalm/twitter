#!/usr/bin/env ruby
require 'set'
require 'time'

country_hash_tags = %W{usa mex aus hon bra ger par uru chi arg alg civ gha nga
          cmr rsa prk kor jpn nzl eng ned den fra
          esp por sui ita svn svk srb gre}.collect{|t| "#"+t}.sort

other_tokens = []#'goal', '#worldcup']

tokens_to_capture = country_hash_tags + other_tokens

hour_offset = nil

STDIN.each do |time_and_tweet|
  time, tweet = time_and_tweet.split("\t")

  interesting_tokens = tweet.gsub(/[^a-z#]/,' ').split(' ').select { |t| tokens_to_capture.include?(t) }
  next if interesting_tokens.empty?

#  time = Time.at(time.to_i)
#  dts = "#{time.to_i} #{Time.at(time.to_i)} "#sprintf("%d_%02d_%02d_%02d", time.year, time.month, time.day, time.hour)

  seconds = time.to_i
  hours = seconds / 60 / 60
  hour_offset ||= hours
  hours -= hour_offset

  interesting_tokens.each { |token| puts "#{hours}\t#{token}" }

end





