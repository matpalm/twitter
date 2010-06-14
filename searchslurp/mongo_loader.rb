require 'rubygems'
require 'init_mongo.rb'
require 'time'

class MongoLoader

  def load search_results

    if search_results.has_key? 'results'
      col = connect_to_mongo
      existing_records = new_records = 0
      search_results['results'].each do |tweet|
        id = tweet['id']
        if col.find("id"=>id).count == 1
          existing_records += 1
        else
          created_at_str = tweet['created_at']
          epoch_time = Time.parse(created_at_str).to_i
          tweet['epoch_time'] = epoch_time
          col.insert(tweet)
          new_records += 1
        end      
      end
      puts "#existing_records=#{existing_records} #new_records=#{new_records} total_number_records=#{col.count.commaify}"
    end
  end

end
