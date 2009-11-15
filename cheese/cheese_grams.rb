#!/usr/bin/env ruby

raise "cheese_grams.rb SIZE" unless ARGV.length==1
N_GRAM_SIZE = ARGV[0].to_i

STDIN.each do |line|
	words = line.split ' '
	non_blank_words = words.select { |word| !word.empty? }

	next unless non_blank_words.size >= N_GRAM_SIZE

	n_gram = []
	N_GRAM_SIZE.times { n_gram << non_blank_words.shift }
	puts n_gram.join ' '

	while !non_blank_words.empty?
		n_gram.shift
		n_gram << non_blank_words.shift
		puts n_gram.join ' '
	end

end
