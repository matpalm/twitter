data = load 'sdf' as (id:chararray, rating:float);
by_id = group data by id;
sum = foreach by_id { generate group, SUM(data.rating) as rating_sum; }
sum_sorted = order sum by rating_sum desc;
top_100 = limit sum_sorted 100;
store top_100 into 'sum_sorted';

