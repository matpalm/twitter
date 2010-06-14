require 'rubygems'
require 'mongo'
require 'json'

class Fixnum
  def commaify
    self.to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
  end
end

def connect_to_mongo
  mongo = Mongo::Connection.new
  db = mongo.db 'tweets'
  db['tweets']
end

