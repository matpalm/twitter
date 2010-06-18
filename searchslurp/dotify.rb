#!/usr/bin/env ruby

class Array

  def rescale! new_min, new_max
    
    current_min = current_max = self.first
    self.each do |val|
      if val < current_min
        current_min = val
      elsif val > current_max
        current_max = val
      end      
    end
    return if current_min == current_max

    current_diff = current_max - current_min

    new_min, new_max = new_max, new_min if new_min > new_max
    new_diff = new_max - new_min
    self.each_with_index do |val, idx|
      rescaled_to_min = (val - current_min).to_f 
      normalised = rescaled_to_min / current_diff
      projected = (normalised * new_diff) + new_min
      self[idx] = projected
    end
  end

end

freqs = []
pairs = []
STDIN.each do |line|
  freq,t1,t2 = line.chomp.split
  freqs << freq.to_i
  pairs << [t1,t2]
end

puts freqs.sort.inspect
freqs.rescale!(6600,66000)
puts freqs.sort.inspect
exit 0

min_freq = max_freq = nil
data.each do |row|
  freq = row.first
  if min_freq.nil?
    min_freq = max_freq = freq
  elsif freq < min_freq
    min_freq = freq
  elsif freq > max_freq
    max_freq = freq
  end
end

puts "min=#{min_freq} max=#{max_freq}"

exit 0

puts "graph {"
data.each do |row|
  freq,t1,t2 = row
  puts "\"#{t1}\" -- \"#{t2}\""
end
puts "}"
