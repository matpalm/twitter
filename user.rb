require 'rubygems'
require 'open-uri'
require 'hpricot'

class User

    attr_accessor :uid

    def initialize uid
        @uid = uid
        @cache = {}
    end

    def screen_name
        doc = dload "http://twitter.com/users/show/#{uid}"
        @screen_name ||= (doc/'screen_name').inner_html
    end

    def following_ids
        doc = dload "http://twitter.com/friends/ids.xml?id=#{id}"
        @following_ids ||= (doc/'id').collect {|e| e.inner_html.to_i}
    end

    def num_following
        doc = dload "http://twitter.com/users/show/#{uid}"
        @num_following ||= (doc/'friends_count').inner_html.to_i
    end

    def num_followers
        doc = dload "http://twitter.com/users/show/#{uid}"
        @followers_count ||= (doc/'followers_count').inner_html.to_i    
    end

    def id
        doc = dload "http://twitter.com/users/show/#{uid}"
        @twitter_id ||= (doc/'user/id').inner_html.to_i
    end

    def popularity
        num_followers.to_f / num_following      
    end

    protected

    def dload uri
        @cache[uri] ||= Hpricot(open(uri).read)
    end

end
