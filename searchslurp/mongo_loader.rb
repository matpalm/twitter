require 'rubygems'
require 'init_mongo.rb'
require 'time'
require 'sanitise.rb'



class MongoLoader

  def load search_results

    sanitiser = Sanitiser.new(:duplicate_spaces_removed)

    if search_results.has_key? 'results'
      col = connect_to_mongo
      existing_records = new_records = 0
      search_results['results'].each do |tweet|
        id = tweet['id']
        if col.find("id"=>id).count == 1
          existing_records += 1
        else
          # insert epoch time
          created_at_str = tweet['created_at']
          epoch_time = Time.parse(created_at_str).to_i
          tweet['epoch_time'] = epoch_time

          # insert sanitised version of text
          tweet['sanitised_text'] = sanitiser.sanitise(tweet['text'])

          # remove guff
          tweet.delete 'profile_image_url'

          # save
          col.insert(tweet)
          new_records += 1
        end      
      end
      puts "#existing_records=#{existing_records} #new_records=#{new_records} total_number_records=#{col.count.commaify}"
    end
  end

end
