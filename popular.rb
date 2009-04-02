#!/usr/bin/env ruby
require 'user'
raise "usage: popular.rb TWITTER_USER TWITTER_PWD" unless ARGV.length == 2

UID, PWD = ARGV

main_user = User.new UID

users = main_user.following_ids.collect { |fid| User.new fid }
users << main_user

users = users.select { |u| u.num_following > 0 }
users = users.sort_by { |u| u.popularity }.reverse

users.each do |u|
    printf "%s %d %d %03f\n", u.screen_name, u.num_following, u.num_followers, u.popularity
end

