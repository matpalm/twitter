#!/usr/bin/env ruby
require 'set'
require 'time'

codes = %W{ kor gre arg nga usa eng alg svn aus ger }

=begin
codes = %W{usa mex aus hon bra ger par uru chi arg alg civ gha nga
          cmr rsa prk kor jpn nzl eng ned den fra
          esp por sui ita svn svk srb gre}.sort
=end

code_to_country_name = {
  'usa' => 'usa', 'mex' => 'mexico', 'hon' => 'honduras',
  'bra' => 'brazil', 'par' => 'paraguay', 'uru' => 'uruguay',
  'chi' => 'chile', 'arg' => 'argentina', 'alg' => 'algeria',
  'civ' => "cote divoire", 'gha' => 'ghana', 'nga' => 'nigeria',
  'cmr' => 'cameroon', 'rsa' => 'south africa', 'prk' => 'korea dpr',
  'kor' => 'korea republic', 'jpn' => 'japan', 'aus' => 'australia',
  'nzl' => 'new zealand', 'eng' => 'england', 'ned' => 'netherlands',
  'den' => 'denmark', 'ger' => 'germany', 'fra' => 'france', 
  'esp' => 'spain', 'por' => 'portugal', 'sui' => 'switzerland',
  'ita' => 'italy', 'svn' => 'slovenia', 'svk' => 'slovakia',
  'srb' => 'serbia', 'gre' => 'greece' }

country_name_to_code = {}
code_to_country_name.each { |k,v| country_name_to_code[v] = k }

# our main datastructure
# datetimestamp -> code -> freq
dts_code_freq = {}

STDIN.each do |time_and_tweet|
  time, tweet = time_and_tweet.split("\t")

  time = Time.at(time.to_i)
  dts = [time.year, time.month, time.day, time.hour]
  dts_code_freq[dts] ||= Hash.new 0

  tokens = tweet.split(" ")
  hash_tags = tokens.select{|t| t=~/^#/}
  hash_tags.each do |hashtag|
    adjacent_tags = hashtag.split("#") # to handle case of #aus#nzl
    adjacent_tags.shift # always a blank first entry
    adjacent_tags.each do |tag|
      tag.gsub! /[^a-z]/,''
      next unless codes.include? tag
      dts_code_freq[dts][tag] += 1
    end
  end

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
codes.each do |code|
  puts "data.addColumn('number','#{code_to_country_name[code]}');"
end
rows = dts_code_freq.keys.collect do |dts|
  data = "[new Date(#{dts.join(',')}),"
  data += codes.collect { |code| dts_code_freq[dts][code].to_s || "undefined" }.join(',')
  data += "]"
end
puts "data.addRows([#{rows.join(',')}]);"

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




