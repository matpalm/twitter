#!/usr/bin/env ruby

require 'ubigraph'

markov_chain_forwards = {}
markov_chain_backwards = {}

word_freq = {}
word_freq.default = 0

total_words = 0

graph = UbiGraph.new

STDIN.each do |tweet|
	tweet_with_amps_spaced = tweet.chomp.gsub(/&/, ' & ')
	words = tweet_with_amps_spaced.split /[ .]/
	non_blank_words = words.select { |word| !word.empty? }

	last_word = non_blank_words.shift
	non_blank_words.each do |word|

		total_words += 1

		word_freq[word] += 1

		markov_chain_backwards[word] ||= {}
		markov_chain_backwards[word][last_word] ||= 0
		markov_chain_backwards[word][last_word] += 1

		markov_chain_forwards[last_word] ||= {}
		markov_chain_forwards[last_word][word] ||= 0
		markov_chain_forwards[last_word][word] += 1

		weight = markov_chain_forwards[last_word][word] 
		puts "add edge, #{last_word} -> #{word}, #{weight}"
		graph.add_edge last_word, word, weight

		last_word = word
	end
end

puts word_freq.to_a.sort {|a,b| a[1]<=>b[1]}.inspect
puts markov_chain_forward.inspect
puts markov_chain_backwards.inspect




