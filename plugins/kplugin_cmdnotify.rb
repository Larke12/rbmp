=begin

AUTHOR:
 Kesiev <http://www.kesiev.com>

WHAT IT DOES:
 Shows desktop notifies without using the rnotify library.
 Instead, it uses the notify-send, commonly shipped with the
 libnotify package.

BUGS:
 - Full size covers :(

=end
alias cmdnotify_notify notify
def notify(me)
	cmdnotify_notify(me)
	if me.state[0]==:play
		attr=[ $window.title , me.meta[:title] + "\n" + me.meta[:artist]+" - " + me.meta[:album] , $covername.to_s]
		attr.length.times { |i| attr[i].gsub!(/([\\$"`])/,'\\\\\1') if attr[i][/([\\$"`])/] }
		command="notify-send \"%s\" \"%s\" " % attr
		if attr[2] then command+="-i \"#{attr[2]}\"" end
		`#{command}`
	end
end
