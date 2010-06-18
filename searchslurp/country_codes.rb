#!/usr/bin/env ruby
require 'set'
require 'time'

country_hash_tags = Set.new(%W{usa mex aus hon bra ger par uru chi arg alg civ gha nga
          cmr rsa prk kor jpn nzl eng ned den fra
          esp por sui ita svn svk srb gre}.collect{|t| "#"+t})

STDIN.each do |time_and_tweet|
  time, tweet = time_and_tweet.split("\t")

  tokens = Set.new(tweet.gsub(/[^a-z#]/,' ').split(' '))
  tokens.delete '#worldcup'

  country_codes_in_this_tweet = country_hash_tags.intersection(tokens)

  country_codes_in_this_tweet.each do |code|
    puts code.sub(/^#/,'')
  end

end





