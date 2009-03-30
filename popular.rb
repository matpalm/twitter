#!/usr/bin/ruby
require 'user'
raise "usage: popular.rb TWITTER_USER" unless ARGV.length == 1

main_user = User.new ARGV[0]

users = main_user.following_ids.collect { |fid| User.new fid }
users << main_user

users = users.select { |u| u.num_following > 0 }
users = users.sort_by { |u| u.popularity }.reverse

users.each do |u|
    printf "%s %03f\n", u.screen_name, u.popularity
end

