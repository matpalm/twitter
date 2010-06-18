freq_country_tokens_d1 = load '$input' as (freq:long, c1:chararray, c2:chararray);
freq_country_tokens_d2 = foreach freq_country_tokens_d1 generate freq, c2, c1;

freq_country_tokens = union freq_country_tokens_d1, freq_country_tokens_d2;

grouped_by_c1 = group freq_country_tokens by c1;

topn_by_country = foreach grouped_by_c1 {
	sorted = order freq_country_tokens by freq desc;
	topn = limit sorted 5;
	generate flatten(topn);
	};

store topn_by_country into '$output';

