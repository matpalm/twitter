require 'rubygems'
require 'time'
require 'sanitise.rb'
require 'init_mongo'

class MongoLoader

  def initialize
    connect
  end

  def connect
    @mongo = Mongo::Connection.new
    db = @mongo.db 'tweets'
    @col = db['tweets']
    @col.create_index("id")
    @col.create_index("epoch_time")
  end
  
  def load search_results, query

    sanitiser = Sanitiser.new(:duplicate_spaces_removed)

    if search_results.has_key? 'results'

      connect unless @mongo.connected?

      existing_records = new_records = 0
      search_results['results'].each do |tweet|
        id = tweet['id']
        if @col.find("id"=>id).count == 1
          existing_records += 1
        else

          # insert query used to find this 
          # note: doesnt mean other queries WOULDNT have found it...
          tweet['found_with_query'] = query

          # insert epoch time
          created_at_str = tweet['created_at']
          epoch_time = Time.parse(created_at_str).to_i
          tweet['epoch_time'] = epoch_time

          # insert sanitised version of text
          tweet['sanitised_text'] = sanitiser.sanitise(tweet['text'])

          # remove guff
          tweet.delete 'profile_image_url'

          # save
          @col.insert(tweet)
          new_records += 1
        end      
      end
      printf "#existing=#{existing_records} #new=#{new_records} #total=#{@col.count.commaify} "
    end
  end

end
