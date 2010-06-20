freq_time_pair = load '$input' as (freq:long, time:long, pair:chararray);
grouped_by_time = group freq_time_pair by time;
topn_by_time = foreach grouped_by_time {
	sorted = order freq_time_pair by freq desc;
	topn = limit sorted $topn;
	generate flatten(topn);
	};
store topn_by_time into '$output';

