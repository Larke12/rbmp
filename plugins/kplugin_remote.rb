=begin

  AUTHOR:
   Kesiev <http://www.kesiev.com>
  	
  WHAT IT DOES:
   A tiny but really powerful remote control for kesievchiefs!
   Open your browser to:
   
   http://<your address>:5000/kesievchiefs?
   
   Remember the question mark! ;)
   And start remoting! "remote" supports different layouts - for
   many devices... will. The default one is plain HTML. You can view an
   iPod-ish interface at:
   
   http://<your address>:5000/kesievchiefs?template=ipod
   
   More templates to come!
   You can change the remote port changing the :remoteport attribute
   in your settings file.

=end

# Setting the default value on load show this option into the settings plugin.
if $opt[:remoteport]==nil then $opt[:remoteport] = 5000 end

remote_templates={

	:default => {
		:listheader => "<html><head><title>@PAGETITLE@</title></head><body>",
		:listitem => "<a href=\"@LINK@\">@LABEL@</a><br>",
		:listfooter => "</body><html>",
		:listseparator => "<h2>@LABEL@</h2>",
		
		:coverboxheader => "<html><head><title>@PAGETITLE@</title></head><body><h2>Coverbox</h2>",
		:cover => "<a href=\"@URL@\"><img src=\"@COVERURL@\"></a><br>",
		:coverna => "<a href=\"@URL@\">@ALBUMNAME@</a><br>",
		:coverboxfooter => "<a href=\"@BACK@'\">Go to...</a></body></html>",


		:filter => "<html><head><title>@PAGETITLE@</title><body>Filter: <form method=\"POST\" action=\"@SEARCHTARGET@\"><input type=\"text\" name=\"query\"> <input type=\"submit\" name=\"ok\" value=\"Search\"> <a href=\"@CANCEL@\">Cancel</a> <a href=\"@REMOVEFILTER@\">Remove filter</a></form></body></html>",
		
		:playscreen => "<html><head><title>@TITLE@</title><meta http-equiv=\"refresh\" content=\"10;@PLAYURL@\"></head><body><center>@COVER@<br><b><a href=\"@SONGMENU@\">@TITLE@</a></b><br><i>@ARTIST@ - @ALBUM@</i><br><span style=\"@SHOWIFPAUSED@\">[PAUSED]</span><br><a href=\"@GOTOLINK@\">Go to...</a><hr><a href=\"@REWINDLINK@\">rewind</a> <a href=\"@PAUSELINK@\">pause</a> <a href=\"@FORWARDLINK@\">forward</a> <a href=\"@STOPLINK@\">stop</a> <a href=\"@STOPLINK@\">fullscreen</a><hr><b>progress</b>: @PROGRESS@ (@PROGRESSTEXT@)</body><html>"
	},
	:ipod => {
		:css => "body{ font-family:Helvetica;background-color:#FFFFFF;overflow-x: hidden;-webkit-text-size-adjust:none;-webkit-user-select: none;}\n.emptycover{cursor:pointer;font-size:12px;text-overflow:ellipsis;overflow:hidden;border:5px solid #000000;float:left;height:150px;width:150px;background-color:#222222;color:#FFFFFF}\n.menu { table-layout:fixed;width:100% }\n.listsection { color:#FFFFFF;padding-left:5px;border-bottom:1px solid #989EA4;border-top:1px solid #A5B1BA;height:23px;font-size:18px;line-height:18px;font-weight:bold;background-color:#92A0AB;padding-left:12px;text-shadow:0 1px 0 #64696E;}\n.item{font-size:17px;font-weight:bold;padding-left:10px;padding-right:10px;border-bottom:1px solid #E1E1E1;height:44px;cursor:pointer;text-overflow:ellipsis;white-space:nowrap;overflow:hidden}\n.head{ letter-spacing:-1px;text-align:center; border-bottom:1px solid #000000;height:44px;font-weight:bold;background-color:#7D91AC;color:#ffffff;font-size:20px;text-shadow:0 -1px 0 #424E5D;}\n.player{width:100%;height:100%}\n.playhead{ letter-spacing:-1px;text-align:center; border-bottom:1px solid #000000;height:44px;font-weight:bold;background-color:#222222;color:#FFFFFF;font-size:12px;text-shadow:0 -1px 0 #424E5D;}\n.playfoot{height:50px;background-color:#222222}\n.cover{background-color:black}\n.button{text-align:center;color:white;font-size:25px;cursor:pointer}\n.gauge{border-top:1px solid #000000;height:20px;background-color:#222222}\n.elapsed{text-overflow:ellipsis;white-space:nowrap;overflow:hidden;background-color:red;font-size:9px;text-align:right;padding-right:5px}\n.rest{background-color:#222222}\n.tablegauge{empty-cells: show;table-layout:fixed;}",
		
		:listheader => "<html><head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\" /><link rel=\"stylesheet\" type=\"text/css\" href=\"/kesievchiefs?template=ipod&page=css\" /><title>@PAGETITLE@</title></head><body onLoad=\"setTimeout(scrollTo, 0, 0, 1);\" topmargin=0 bottommargin=0 leftmargin=0 rightmargin=0><table cellpadding=0 cellspacing=0 class=menu><tr><td class=head>@PAGETITLE@</td></tr>",
		:listitem => "<tr><td onClick=\"document.location.href='@LINK@'\" class=item>@LABEL@</td></tr>",
		:listfooter => "</table></body></html>",
		:listseparator => "<tr><td class=listsection>@LABEL@</td></tr>",

		:coverboxheader => "<html><head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\" /><link rel=\"stylesheet\" type=\"text/css\" href=\"/kesievchiefs?template=ipod&page=css\" /><title>@PAGETITLE@</title></head><body onLoad=\"setTimeout(scrollTo, 0, 0, 1);\" topmargin=0 bottommargin=0 leftmargin=0 rightmargin=0><table cellpadding=0 cellspacing=0 class=menu height=100%><tr><td class=head>@PAGETITLE@</td></tr><tr><td align=center style=\"background-color:black\" valign=top align=middle>",
		:cover => "<img onClick=\"document.location.href='@URL@'\" class=emptycover src=\"@COVERURL@\">",
		:coverna => "<div onClick=\"document.location.href='@URL@'\" class=emptycover>@ALBUMNAME@</div>",
		:coverboxfooter => "</td><tr><td onClick=\"document.location.href='@BACK@'\" class=item>Go to...</td></tr></tr></table></body></html>",
		
		:filter => "<html><head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\" /><link rel=\"stylesheet\" type=\"text/css\" href=\"/kesievchiefs?template=ipod&page=css\" /><title>@PAGETITLE@</title></head><body onLoad=\"setTimeout(scrollTo, 0, 0, 1);\" topmargin=0 bottommargin=0 leftmargin=0 rightmargin=0><form name=\"finder\" method=\"POST\" action=\"@SEARCHTARGET@\"><table cellpadding=0 cellspacing=0 class=menu><tr><td class=head>@PAGETITLE@</td></tr><tr><td class=item><input type=\"text\" style=\"height:100%;width:100%;font-size:17px;\" name=\"query\"></td></tr><tr><td onClick=\"document.finder.submit()\" class=item>Filter</td></tr><tr><td onClick=\"document.location.href='@REMOVEFILTER@'\" class=item>Remove filter</td></tr><tr><td onClick=\"document.location.href='@CANCEL@'\" class=item>Cancel</td></tr></table></form></body></html>",
		
		:playscreen => "<html><head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\" /><meta http-equiv=\"refresh\" content=\"10;@PLAYURL@\"><link rel=\"stylesheet\" type=\"text/css\" href=\"/kesievchiefs?template=ipod&page=css\" /><title>@TITLE@</title></head><body topmargin=0 bottommargin=0 leftmargin=0 rightmargin=0><table class=player cellspacing=0 cellpadding=0><tr><td class=playhead onClick=\"document.location.href='@GOTOLINK@'\"><b>@TITLE@</b><br><i>@ARTIST@ - @ALBUM@<span style=\"@SHOWIFPAUSED@\"> [PAUSED]</span></i></td></tr><tr><td valign=middle align=center class=cover onClick=\"document.location.href='@SONGMENU@'\">@COVERFULLH@</td></tr><tr><td class=gauge><table cellpadding=0 cellspacing=0 border=0 width=100% height=100% class=tablegauge style=\"visibility:@SHOWIFPERCENTAGE@\"><tr><td class=elapsed width=@PERCENTAGE@%>@PROGRESSTEXT@</td><td class=rest></td></tr></table></td></tr><tr><td class=playfoot valign=middle align=center><table cellpadding=0 cellspacing=3 width=100% border=0><tr><td onClick=\"document.location.href='@REWINDLINK@'\" class=button>&laquo;</td><td onClick=\"document.location.href='@PAUSELINK@'\" class=button>||</td><td onClick=\"document.location.href='@FORWARDLINK@'\" class=button>&raquo;</td><td onClick=\"document.location.href='@STOPLINK@'\" class=button>[]</td><td onClick=\"document.location.href='@FULLSCREENLINK@'\" class=button>fs</td></tr></table></td></tr></table></body></html>"
	}
}

# Quick htmlentities function
def htmlentities(string)
	ret=""
	string.each_byte  { |letter|
		# do not encode numbers, spaces (encoded later), A-Z, a-z
		if (letter>=48 && letter<=57) || letter==32 || (letter>65 && letter<=90) || (letter>= 97 && letter<=122) then
			ret+=letter.chr
		else
		# encodes the rest
			ret+='&#x'+sprintf("%x", letter)+";"
		end
	}
	ret.gsub(/  /,"&nbsp;&nbsp;");
end

# Proxies the urls to the remote when "surf" is called
$REMOTE_CATCH_URL=nil
alias remote_surf surf
def surf(url) 
	if $REMOTE_CATCH_URL=="" then
		$REMOTE_CATCH_URL=url
	else
		remote_surf(url)
	end
end  

# Shut down politely when application is closed
alias remote_shutdown shutdown
def shutdown(from)
  $remote_server.shutdown
  remote_shutdown(from)
end

# Options shown in quite every menu for quick access
def remote_bookmarks(list)
	list << { :label => "Navigation" }
	list << {:label => "Now playing...", :link => "page=play" }
	list << {:label => "Go to...", :link => "page=goto" }
end

# Coverbox is simulated and bad implemented... sorry.
def remote_coverbox(tid,model)
	htmldata=""
	cache=[]
	if File.exists?($section[:albums]) then
		open($section[:albums], "r").each { |line|
		  details = unformatrecord(:albums,line)
		  if ($curartist == $opt[:all] || details[:artist].chomp == $curartist ) && cache.index(details[:album])==nil then
			  cache << details[:album]

			  if File.exist?(cfile=getcovername(details[:artist].chomp,details[:album])) then
				entry=model[:cover]
			  else
				entry=model[:coverna]
			  end
			  entry=entry.gsub(/@COVERURL@/,"kesievchiefs?template=#{tid}&page=cover&file="+File.basename(cfile))
			  entry=entry.gsub(/@ALBUMNAME@/,htmlentities(details[:album]))
			  entry=entry.gsub(/@URL@/,"kesievchiefs?template=#{tid}&page=songs&album=#{cache.length}")
			  htmldata+=entry
			  
		 end
	  }
	end
	htmldata
end

# convert a menu in a list of option
def remote_menutolist(menuid,list)
	title="Unknown menu"
	$menulist.each { |men|
		if men[:id]==menuid then
			title="#{men[:label]} menu"
		end
	}
	list << {:label => title }
	$menus.each_with_index { |men,i|
		if men[:menu]==menuid then
			list <<  { :label=>men[:label], :link => "page=play&clickmenu=#{i}" }
		end
	}
	title
end


Thread.new {

	$remote_server = WEBrick::HTTPServer.new( :Port => $opt[:remoteport] )

	$remote_server.mount_proc("/kesievchiefs"){|req, res|
	  if (req.query_string!=nil) 
	  	attrs={}
	  	items=[]
	  	res.body=""
	  	title=""
	  	
	  	req.query_string.split("&").each { |value| spl=value.split("=");attrs[spl[0].intern]=spl[1]; }
		req.query.collect { | key, value | attrs[key.intern]=value }
	  	
	  	# defaults
	  	if attrs[:template]==nil then attrs[:template]="default" end
	  	if attrs[:page]==nil then attrs[:page]="play" end

	  	# Selectors
	  	if attrs[:section]!=nil then
	  		setmode($lists[attrs[:section].to_i])
	  	end
	  	if attrs[:artist]!=nil then
	  		iter=$artistslist.get_iter(attrs[:artist])
	  		$artists.selection.select_iter(iter)
			$curartist=iter[0]
			updatealbums	  	
	  	end
	  	if attrs[:album]!=nil then
	  		iter=$albumslist.get_iter(attrs[:album])
	  		$albums.selection.select_iter(iter)
			$curalbum=iter[0]
			updatesongs	  	
	  	end
	  	if attrs[:song]!=nil then
	  		iter=$songslist.get_iter(attrs[:song])
	  		$songs.selection.select_iter(iter)
			play(iter)
	  	end
	  	if attrs[:clickmenu]!=nil then
	  		$REMOTE_CATCH_URL=""
	  		$menus[attrs[:clickmenu].to_i][:action].call()
	  		if ($REMOTE_CATCH_URL!="") then
	  			attrs[:page]="redirect"
	  		else
	  			$REMOTE_CATCH_URL=nil
	  		end
	  	end
	  	if attrs[:query] then
			$lookup.text=attrs[:query]
			# kill the lookup thread
			if $lookupthread then $lookupthread.kill end
			updatesongs
		end
	  	if attrs[:action]!=nil then
	  		case attrs[:action]
	  			when "pause"
	  				$player.control(:pause,nil)
	  			when "forward"
	  				$player.control(:forward,nil)
	  			when "rewind"
	  				$player.control(:rewind,nil)
	  			when "fullscreen"
	  				$player.control(:fullscreen,nil)
	  			when "fullscreen"
	  				$player.control(:fullscreen,nil)
	  			when "stop"
	  				$player.control(:stop,:byhand)
	  		end
	  	end

	  	# template id
	  	tid=attrs[:template].intern;
	  		  		  	
	  	# Detect first page
	  	if attrs[:page]=="detect" then
	  		if $section[:artists] then attrs[:page]="artists" else attrs[:page]="songs" end
	  	end
	  	
	  	# page dispatcher
	  	case attrs[:page]
	  		when "cover"
				res.body=open($opt[:covers]+attrs[:file], "rb") { |f| f.read } 
			when "goto"
				title="Go to..."
	  			items << {:label => title }
				items << {:label => "Now playing...", :link => "page=play" }
				items << {:label => "Lists", :link => "page=lists" }
				items << {:label => "Browse #{$section[:label]}", :link => "page=detect" }
				if $section[:artists] then
					items << {:label => "Artists", :link => "page=artists" }
					items << {:label => "Albums", :link => "page=albums" }
					items << {:label => "Coverbox", :link => "page=coverbox" }
					items << {:label => "Songs", :link => "page=songs" }
				end
	  			items << {:label => "Menus" }
	  			$menulist.each { |men|
					items << {:label => men[:label], :link => "page=menu&menu=#{men[:id]}" }
	  			}
	  		when "lists"
	  			remote_bookmarks(items)
	  			title="Lists"
	  			items << {:label => title }
				$lists.each_with_index { |item,i|
				if !item[:hidden] then
					items << {:label => item[:label], :link => "page=detect&section=#{i}" }
				end
			 }
	  		when "artists"
	  			remote_bookmarks(items)
	  			title="Artists"
	  			items << {:label => title }
	  			$artistslist.each { |model,path,iter| 
					items << {:label => iter[0], :link => "page=albums&artist=#{iter}" }
	  			}
	  		when "albums"
	  			remote_bookmarks(items)
	  			items << {:label => "Coverbox" }
				items << {:label => "Find by cover", :link => "page=coverbox" }
	  			title="Albums"
	  			items << {:label => title }
	  			$albumslist.each { |model,path,iter| 
					items  << {:label => iter[0], :link => "page=songs&album=#{iter}" }
	  			}
	  		when "songs"
	  			remote_bookmarks(items)
	  			items << {:label => "Filter" }
				items << {:label => "Filter list...", :link => "page=filter" }
	  			title="Songs"
	  			items << {:label => title+($lookup.text=="" ? "" : " (filtered)") }
	  			$songslist.each { |model,path,iter| 
					items << {:label => iter[COLMAP[:title]], :link => "page=play&song=#{iter}" }
	  			}
	  		when "menu"
	  			remote_bookmarks(items)
	  			title=remote_menutolist(attrs[:menu].intern,items)
	  		when "filter"
	  			title="Filter"
	  			html=String.new(remote_templates[tid][:filter])
	  			html=html.gsub(/@SEARCHTARGET@/,"kesievchiefs?template=#{tid}&page=songs")
	  			html=html.gsub(/@CANCEL@/,"kesievchiefs?template=#{tid}&page=songs")
	  			html=html.gsub(/@REMOVEFILTER@/,"kesievchiefs?template=#{tid}&page=songs&query=")	  			
	  		when "coverbox"
	  			title="Coverbox"
	  			html=String.new(remote_templates[tid][:coverboxheader])+remote_coverbox(tid,remote_templates[tid])+remote_templates[tid][:coverboxfooter]
	  			html=html.gsub(/@BACK@/,"/kesievchiefs?template=#{tid}&page=goto")
	  		when "songmenu"
	  			title="Current song"
	  			remote_bookmarks(items)
	  			remote_menutolist(:song,items)
	  			remote_menutolist(:lastfm,items)
	  		when "play"
	  			title="Play"
				html=String.new(remote_templates[tid][:playscreen]);
	  			html=html.gsub(/@COVER@/,($covername ? "<img src=\"/kesievchiefs?page=cover&file=#{File.basename($covername)}\">" : ""));
	  			html=html.gsub(/@COVERFULLH@/,($covername ? "<img height=100% src=\"/kesievchiefs?page=cover&file=#{File.basename($covername)}\">" : ""));
	  			html=html.gsub(/@TITLE@/,htmlentities($player.meta[:title])).gsub(/@ARTIST@/,htmlentities($player.meta[:artist].to_s)).gsub(/@ALBUM@/,htmlentities($player.meta[:album].to_s));
	  			html=html.gsub(/@PROGRESS@/,"#{$progress.fraction}").gsub(/@PROGRESSTEXT@/,$progress.text.to_s)
	  			html=html.gsub(/@PLAYURL@/,"/kesievchiefs?template=#{tid}&page=play");
	  			html=html.gsub(/@GOTOLINK@/,"/kesievchiefs?template=#{tid}&page=goto");
	  			html=html.gsub(/@REWINDLINK@/,"/kesievchiefs?template=#{tid}&page=play&action=rewind");
	  			html=html.gsub(/@FORWARDLINK@/,"/kesievchiefs?template=#{tid}&page=play&action=forward");
	  			html=html.gsub(/@PAUSELINK@/,"/kesievchiefs?template=#{tid}&page=play&action=pause");
	  			html=html.gsub(/@STOPLINK@/,"/kesievchiefs?template=#{tid}&page=play&action=stop");
	  			html=html.gsub(/@FULLSCREENLINK@/,"/kesievchiefs?template=#{tid}&page=play&action=fullscreen");
	  			html=html.gsub(/@SONGMENU@/,"/kesievchiefs?template=#{tid}&page=songmenu");
	  			perc=($progress.fraction*100).round
	  			html=html.gsub(/@PERCENTAGE@/,perc.to_s);
	  			html=html.gsub(/@SHOWIFPERCENTAGE@/,(perc==0 ? "hidden" : "show"));
	  			html=html.gsub(/@SHOWIFPAUSED@/,($player.state[0]==:pause ? "" : "display:none"));
	  		when "redirect"
	  			res.body="<html><head><meta http-equiv=\"refresh\" content=\"0;#{$REMOTE_CATCH_URL}\"></head><body></body></html>";
	  			$REMOTE_CATCH_URL=nil;
	  		else
	  			#generic page server for undynamic pages
	  			res.body=remote_templates[tid][attrs[:page].intern]
	  	end
	  	
	  	# formatted list
	  	if items.length>0 then
			html=remote_templates[tid][:listheader];
			items.each { |it|
				if it[:link]==nil then
					item=String.new(remote_templates[tid][:listseparator]);
				else
					item=String.new(remote_templates[tid][:listitem]);				
				end
				html+=item.gsub(/@LABEL@/,htmlentities(it[:label])).gsub(/@LINK@/,"/kesievchiefs?template=#{tid}&#{it[:link]}")
			}
			html+=remote_templates[tid][:listfooter];
			
		end
		# plain html page
		if html then
			res['Content-Type'] = "text/html"
			html=html.gsub(/@PAGETITLE@/,title)
			res.body=html
		end

	  end
	}
	$remote_server.start
}
