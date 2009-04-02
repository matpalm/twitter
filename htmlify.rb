#!/usr/bin/env ruby
every_second = false
puts "<tr><td>user</td><td>#followers</td><td>#following</td><td>popularity</td></tr>"
STDIN.each do |line|
		screen_name, num_following, num_followers, popularity	= line.chomp.split 
    td = every_second ? '<td>' : '<td class="y">'
    every_second = !every_second
    print "<tr>"
    print "#{td}#{screen_name}</td>"
    print "#{td}#{num_followers}</td>"
    print "#{td}#{num_following}</td>"
    printf "%s%03f</td>", td, popularity
    print "</tr>\n"
end

