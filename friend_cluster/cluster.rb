#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'
require 'set'
require 'lingua/stemmer'

mongo = Mongo::Connection.new('localhost',12300)
users_collection = mongo.db('wordbag')['users']

class User
  attr_accessor :name, :tokens
  def initialize name, tokens
    self.name = name
    self.tokens = Set.new(tokens)
  end
  def similiarity_to other_user
    intersection_size = other_user.tokens.intersection(tokens).size
    union_size = other_user.tokens.union(tokens).size
    intersection_size.to_f / union_size
  end
end

users = users_collection.find.collect do |user|
#  name = "#{user['name']} (#{user['screen_name']})"
  name = user['screen_name']

  tokens = user['word_bag']['toks']
  next if tokens.nil?
  tokens = tokens.collect{|t| Lingua.stemmer(t['tok'])}

  User.new name, tokens
end.compact

u1 = users.shift
while not users.empty?
  users.each do |u2|    
    sim = u1.similiarity_to(u2)
    puts [sim,u1.name,u2.name].join("\t") if u1.similiarity_to(u2) > 0
  end
  u1 = users.shift
end

