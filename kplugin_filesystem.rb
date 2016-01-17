=begin

  AUTHOR:
   Kesiev <http://www.kesiev.com>
  	
  WHAT IT DOES:
   Add filesystem destinations, which are indexed on-access.
   Destinations can be added by user, creating a label and a filesystem
   attribute. List can be refreshed manually, pushing the refresh button.
   
   - :label: My filesystem folder
     :filesystem: /home/user/mymusic/

=end

def filesystem_generate(section)
	open(section[:file],"w") { |f|
		Dir.new(section[:filesystem]).select{ |file|
			puts file
      !File.directory?(section[:filesystem]+"/"+file) 
    }.each { |file|
			 f.puts(formatrecord({:artist=>File.extname(file).upcase[1..-1],:title=>file,:file=>section[:filesystem]+"/"+file}))
		}
	}
end

alias filesystem_generateimplicits generateimplicits
def generateimplicits
	filesystem_generateimplicits
	$lists.length.times { |i|
		if $lists[i][:filesystem] then
			$lists[i][:icon]="stock_folder"
			$lists[i][:protected]=true
			$lists[i][:file]="#{$opt[:root]}/filesystem_"+Digest::MD5.hexdigest($lists[i][:filesystem])
			$lists[i][:onclick]=Proc.new { |s| filesystem_generate(s) if !File.exist?(s[:file]); :update}
			$lists[i][:onrefresh]=Proc.new { |s| filesystem_generate(s) }
		end
	}
end
