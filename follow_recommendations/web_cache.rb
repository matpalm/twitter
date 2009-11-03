require 'rubygems'
require 'json'
require 'fileutils'
require 'curl'
require 'rate_limiter'

WEB_CACHE_DIR = 'cache'
HASH_BUCKETS = 20

class TwitterInfo

	def initialize id, cache_filename, fetch_url, rate_limiter
		@cache_filename = "#{WEB_CACHE_DIR}/#{id.to_i % HASH_BUCKETS}/#{cache_filename}" 
		@fetch_url = fetch_url
		@rate_limiter = rate_limiter
	end

	def fetch		
		begin
			download unless File.exists? @cache_filename
			file_contents = File.read(@cache_filename)		
			JSON::parse(file_contents)      
		rescue Exception => e
			STDERR.puts e.inspect
			File.delete @cache_filename
			STDERR.puts "#{Time.now} ERROR with #{@fetch_url} retry in 5s"
			sleep 5
			retry
		end
	end

	def download
		puts "cache miss for #{@fetch_url}"		
		@rate_limiter.checkpoint
		curl @fetch_url, @cache_filename
	end

end

class WebCache

	def initialize
		if !File.exists? WEB_CACHE_DIR
			FileUtils.mkdir_p(WEB_CACHE_DIR) 
			HASH_BUCKETS.times { |n| FileUtils.mkdir_p("#{WEB_CACHE_DIR}/#{n}") }
		end
		@rate_limiter = RateLimiter.new
		@id_to_name = {}
	end

	def name id
		info = user_info_for id
		"#{info["name"]} (#{info["screen_name"]})"
	end
   
	def num_friends_of id
		info = user_info_for id
		info['friends_count']
	end

	def friends_of id
		result = TwitterInfo.new(
			id,
			"friends.#{id}.json", 
			"http://twitter.com/friends/ids.json?id=#{id}",
			@rate_limiter
			).fetch
		result
	end

	def num_followers_of id
		info = user_info_for id
		info['followers_count']
	end

	def followers_of id
		result = TwitterInfo.new(
			id,
			"friends.#{id}.json", 
			"http://twitter.com/followers/ids.json?id=#{id}",
			@rate_limiter
			).fetch
		result
	end
	
	def user_info_for id
		TwitterInfo.new(
			id,
			"user_info.#{id}.json", 
			"http://twitter.com/users/show.json?id=#{id}",
			@rate_limiter
			).fetch
	end

	def invalidate_for id
		`rm #{WEB_CACHE_DIR}/*#{id}*`
	end

end

