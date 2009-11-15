#!/usr/bin/env ruby

class String
	def without_urls 
		gsub(/http.*?\s/,' ').sub(/http.*?$/,' ') # single regex for this? i'm sleepy
	end

	def with_amps_spaced
		gsub /&/, ' & '
	end
	
	def without_punctionation
		gsub('\'','').gsub(/[^a-z0-9&]/, ' ')
	end

	def duplicate_spaces_removed
        	gsub /\s+/, ' '
	end
end

STDIN.each do |line|
	puts line.
		chomp.
		downcase.
		without_urls.
		with_amps_spaced.
		without_punctionation.
		duplicate_spaces_removed
end
