#!/usr/bin/env ruby
require 'set'
require 'time'

# our main datastructure
# datetimestamp -> code -> freq
dts_token_freq = {}
tokens = Set.new
STDIN.each do |freq_time_token|
  freq, time, token = freq_time_token.chomp.split("\s")
  time.gsub!('_',',')
  dts_token_freq[time] ||= {}
  dts_token_freq[time][token] = freq
  tokens << token
end

puts <<EOF
<html>
  <head>
    <script type='text/javascript' src='http://www.google.com/jsapi'></script>
    <script type='text/javascript'>
      google.load('visualization', '1', {'packages':['annotatedtimeline']});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('date', 'Date');
EOF
tokens.each do |token|
  puts "data.addColumn('number','#{token}');"
end
rows = dts_token_freq.keys.collect do |dts|
  data = "[new Date(#{dts}),"
  data += tokens.collect { |token| dts_token_freq[dts][token] || "undefined" }.join(',')
  data += "]"
end
puts "data.addRows([#{rows.join(",\n")}]);"

puts <<EOF
var chart = new google.visualization.AnnotatedTimeLine(document.getElementById('chart_div'));
chart.draw(data, {displayAnnotations: true});
      }
    </script>
  </head>

  <body>
    <div id='chart_div' style='width: 100%; height: 100%'></div>
  </body>
</html>
EOF




