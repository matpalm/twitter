require 'web_cache'
require 'set'

class Set
   def jaccard other
      num = other.intersection(self).size
      denom = other.union(self).size
      num.to_f / denom
   end
end

already_following = Set.new

me = 26970530
already_following << me

cache = WebCache.new
my_friends = Set.new(cache.friends_of(me))
puts "#{me} follows #{my_friends.size} ppl"
already_following += my_friends

friend_num_followers_pairs = []
my_friends.each do |friend|
	num_followers = cache.num_followers_of friend
	puts "#{friend} followed by #{num_followers} ppl"
	friend_num_followers_pairs << [friend,num_followers]
end

# sort by number following
friend_num_followers_pairs = friend_num_followers_pairs.sort {|a,b| a[1] <=> b[1] }
puts "friend_num_followers_pairs=#{friend_num_followers_pairs.inspect}"

candidates = File.new("candidates.tsv","w")

friend_num_followers_pairs.each do |friend_num_followers_pair|
	friend, num_followers = friend_num_followers_pair
	followers = cache.followers_of friend
	puts "----------------check jaccard for #{followers.size} people who also follow #{friend}"
	followers.each do |follower|
		next if me == follower

		num_friends = cache.num_friends_of follower
		if num_friends == 0 || num_friends > 500
			puts "ignore #{follower}, num_friends=#{num_friends}"
			next
		end

		friends_of_follower = Set.new(cache.friends_of(follower)) 
		if friends_of_follower.size == 0
			puts "hmmm, friends_of_follower.size == 0 for follower=#{follower}"
			next
		end

		jaccard = friends_of_follower.jaccard my_friends
		if jaccard == 0
			puts "hmmm, jaccard == 0 for follower=#{follower}"
			next
		end

		friends_of_follower.each do |candidate| 			
			candidates.puts "#{candidate}\t#{jaccard}" unless already_following.include? candidate
		end
		candidates.flush

		puts "follower=#{follower} #friends_of_follower=#{friends_of_follower.size} jaccard=#{jaccard}"
	end
end
