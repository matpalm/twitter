#!/usr/bin/env ruby
every_second = false
STDIN.each do |line|
		screen_name, num_following, num_followers, popularity	= line.chomp.split 
    td = every_second ? '<td>' : '<td class="y">'
    even_second = !even_second
    print "<tr>"
    print "#{td}#{screen_name}</td>"
    print "#{td}#{num_followers}</td>"
    print "#{td}#{num_following}</td>"
    printf "%s%03f</td>", td, popularity
    print "</tr>\n"
end

