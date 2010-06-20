#!/usr/bin/env ruby
require 'set'
require 'time'

country_hash_tags = Set.new(%W{usa mex aus hon bra ger par uru chi arg alg civ gha nga
          cmr rsa prk kor jpn nzl eng ned den fra
          esp por sui ita svn svk srb gre}.collect{|t| "#"+t})

hour_offset = nil

STDIN.each do |time_and_tweet|
  time, tweet = time_and_tweet.split("\t")

  tokens = Set.new(tweet.gsub(/[^a-z#]/,' ').split(' '))
  tokens.delete '#worldcup'

  country_codes_in_this_tweet = country_hash_tags.intersection(tokens)
  
  next unless country_codes_in_this_tweet.size > 0
  country_codes_in_this_tweet = country_codes_in_this_tweet.to_a.map{|t| t.sub(/^#/,'') }

  seconds = time.to_i
  hours = seconds / 60 / 60
  hour_offset ||= hours
  hours -= hour_offset

  tag1 = country_codes_in_this_tweet.shift
  while !country_codes_in_this_tweet.empty?    
    country_codes_in_this_tweet.each do |tag2| 
      tag1,tag2 = tag2,tag1 if tag2<tag1
      puts "#{hours}\t#{tag1}_#{tag2}" 
    end    
    tag1 = country_codes_in_this_tweet.shift
  end

end





