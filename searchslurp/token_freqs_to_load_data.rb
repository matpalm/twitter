#!/usr/bin/env ruby

tag_to_freqs = {}
total_for_time = Hash.new 0
max_time = nil

STDIN.each do |line|
  freq,time,tag = line.split
  freq = freq.to_i
  time = time.to_i
  tag.sub! '#',''

 # puts "#{freq} #{time} #{tag}"

  tag_to_freqs[tag] ||= []
  tag_to_freqs[tag][time] = freq
  
  total_for_time[time] += freq

  max_time ||= time
  max_time = time if time > max_time

end

=begin
puts "max_time=#{max_time}"
puts "tag_to_freqs"
puts tag_to_freqs.inspect
puts "total_for_time"
puts total_for_time.inspect
=end

# normalise sucka!
tag_to_freqs.values.each do |freqs|
  (max_time+1).times do |t| 
    if total_for_time[t] == 0
      freqs[t] = 1.0/32
    else
      current_value = freqs[t] || 0
      new_value = current_value.to_f / total_for_time[t]
      freqs[t] = new_value
    end
  end
end

# start with the 
#puts "tag_to_freqs (post normalisation)"
#puts tag_to_freqs.inspect

# output format is
# records.put("civ", new float[]{0.031,0.029});
tag_to_freqs.each do |tag,freqs|
  freqs_str = freqs.collect { |freq| sprintf("%0.03f",freq) }.join(',')
  puts "((Ball)ballsByCode.get(\"#{tag}\")).targetProportion = new float[]{#{freqs_str}};"
end
