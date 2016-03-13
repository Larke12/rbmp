#!/usr/bin/ruby

require 'gtk3'
require 'find'
require 'open-uri'
require 'digest/md5'
require 'webrick'
require 'rexml/document'
require 'yaml'
#require 'nokogiri'
#require 'gir_ffi'

begin $notifies=require 'rnotify'; rescue LoadError; end

# Numcols (numeric columns)
# Colpvt (non-databased columns)
# Colmap (Columns mappings from backend to table)
# Databases (Backend columns names)
# Labels (Column labels for the $opt[:columns] parameter
NUMCOLS, COLPVT, COLMAP, DATABASES, LABELS, $opt = [:trackno, :year], {:order=>9, :lineno=>10}, { :title => 0 , :artist => 1 , :album => 2 , :year=>3, :trackno => 4 , :file=>5, :url => 6,  :cover=>7 , :custommeta=>8} , {:artists=>[:artist],:albums=>[:album,:artist],:file=>[:artist,:album,:trackno,:year,:title,:url,:file,:cover,:custommeta]} , {:title=>"Media", :artist=>"Artist", :album=>"Album", :year=>"Year", :trackno=>"Track", :url=>"URL", :file=>"File"},  {:root=>"#{ENV['HOME']}/.rbmp"}

$opt.merge!({ :columns=>[:title,:artist,:album,:year,:trackno],:loadplugins=>[],:height=>600,:width=>600,:defaultentries=>true,:separator=>"#!#", :all=>"(All)", :unknown=>"Unknown", :serverport=>"12345", :iconsize=>15, :settings=>"#{$opt[:root]}/settings", :plugins=>"#{$opt[:root]}/plugins", :purple=>(%x[which purple-remote]!=""),:showcover=>true,:coverh=>105,:coverw=>105,:covers=>"#{$opt[:root]}/cover/", :coverbox=>true, :coverboxheight=>150, :coverboxh=>105, :coverboxw=>105,:filterheight=>100,:lastfmuser=>"", :lastfmpass=>"", :musicroot=>"#{ENV['HOME']}/Music/" })

# Reads settings
if File.exist?($opt[:settings]) && (configdata=YAML::load_file($opt[:settings])) && configdata[:opt] 
	then $opt.merge!(configdata[:opt]).each_key { 
		|k| $opt[k].gsub!(/\{[^}]*\}/) { |pattern| ENV[pattern[1..-2]] } if $opt[k].class==String } 
end 

# built in lists	
$lists=[ {:label=>"Music",:root=>"#{$opt[:musicroot]}",:artists=>"#{$opt[:root]}/artists", :albums=>"#{$opt[:root]}/albums",:file=>"#{$opt[:root]}/songs"},
	#{:label=>"Radio streams", :file=>"#{$opt[:root]}/streams",:backend=>"http://www.shoutcast.com/",:rename=>"_scurl.*\">(.*)<" ,:redata=>"(\\/sbin\\/shoutcast-playlist\\.pls\\?rn=[0-9]*&file=filename\\.pls)", :prefix=>"http://www.shoutcast.com"},
	#{:label=>"TVs", :file=>"#{$opt[:root]}/tvs",:backend=>"http://wwitv.com/television/104.htm",:rename=>"target=\"TV\">(.*)<\\/a>.*" ,:redata=>"listen\\(.*','(.*\\.asx)'," },
	#{:label=>"LastFM Stations", :file=>"#{$opt[:root]}/lastfm",:backend=>"http://www.lastfm.com/music/+tags/",:rename=>"style=\"font-size.*href[^>]*>([^<]*)" ,:redata=>"style=\"font-size.*href=\"\\/tag\\/([^\"]*)",:prefix=>"lastfm://globaltags/", :encodeurl=>true},	
	($opt[:defaultentries] ? {:icon=>"connect_established",:label=>"#{ENV['USER']}'s Music",:protected=>true,:root=>"http://127.0.0.1:#{$opt[:serverport]}/",:file=>"http://127.0.0.1:#{$opt[:serverport]}/songs"} : nil) , # add your shares like this.
	#($opt[:defaultentries] ? {:label=>"Amplified podcast",:xml=>"http://feeds.feedburner.com/amplified"} : nil), # Basic podcast/rss support.
	($opt[:defaultentries] ? {:icon=>"emblem-favorite",:label=>"Favourites",:file=>"#{$opt[:root]}/favourites"} : nil ) # Here comes the custom playlists! Add lines like this for more custom playlists.
].compact

# Built-in menus
$menulist=[{:label=>"File" , :id=>:file}, {:label=>"Song", :id=>:song}, { :label => "Playlist", :id=>:playlist }, { :label=>"LastFM", :id=>:lastfm}, {:label=>"Help", :id=>:help } ]
$menus=[ {:menu=>:song, :label=>"Visit related link", :action=>Proc.new {if $player.meta[:url].to_s!="" then surf($player.meta[:url].to_s) else $statbar.push($statbar.get_context_id("relatedurl"),"Sorry, any related link on \"#{$player.meta[:title]}\".") end} },
  {:menu=>:song, :label=>"YouTube for song", :action=>Proc.new{surf("http://www.youtube.com/results?q=%s" % [URI.escape($player.meta[:artist]+" "+$player.meta[:album]) ]) } },
  {:menu=>:song, :label=>"Google for song", :action=>Proc.new{surf("http://www.google.com/search?q=%s"  % [URI.escape($player.meta[:artist]+" "+$player.meta[:album])] )  } },
  {:menu=>:song, :label=>"Lyrics for title", :action=>Proc.new{surf("http://www.seeklyrics.com/search.php?q=%s&t=1" % [URI.escape($player.meta[:title])] ) } },
  {:menu=>:song, :label=>"Wikipedia for artist", :action=>Proc.new{surf("http://en.wikipedia.org/wiki/%s" % [URI.escape($player.meta[:artist])] ) } },
  {:menu=>:song, :label=>"Wikipedia for album", :action=>Proc.new{surf("http://en.wikipedia.org/wiki/%s" % [URI.escape($player.meta[:album])] ) }  },
  {:menu=>:help, :label=>"About...", :action=>Proc.new{Gtk::AboutDialog.show($window,{:program_name=>$window.title,:authors=>["KesieV"],:comments=>"A compact media player in "+(File.open(__FILE__,"r") { |f| f.select { |line| !line[/^[ \t]*#/] && line.strip.length>0} }).length.to_s+" lines of Ruby.\nUses Mplayer as backend.\nThanks to Bianca & Ulrick for supporting!",:website=>"http://www.kesiev.com"})} },
  {:menu=>:file, :label=>"Update all podcasts", :action=>Proc.new{ Thread.new { $modeslist.each { |model,path,iter| if $lists[iter[3].to_i][:xml] && ((File.exist?($lists[iter[3].to_i][:file]) ? Digest::MD5.hexdigest(File.read($lists[iter[3].to_i][:file])) : "" ) != makedatabasepodcast($lists[iter[3].to_i],true)) then iter[1]=1 end  } } } },
  {:menu=>:file, :label=>"Share/Unshare my music", :action=>Proc.new{
	if $musicshare == nil
		($musicshare=WEBrick::HTTPServer.new(:Port => $opt[:serverport], :DocumentRoot => $lists[0][:root])).mount("/songs",WEBrick::HTTPServlet::FileHandler,$lists[0][:file],true)
		Thread.new { $musicshare.start }
	else
		$musicshare.shutdown
		$musicshare=nil
	end
  } },
  {:menu=>:file, :label=>"Quit", :action=>Proc.new{ if shutdown(:fromquit) then $window.destroy end } },
  {:menu=>:playlist, :label=>"Shuffle", :action=>Proc.new {
	if iter=$songslist.iter_first
		set=(0..$rowcount-1).to_a
		$rowcount.times{iter[COLPVT[:order]]=set.delete_at(rand(set.length)); iter.next! }
		$songslist.set_sort_column_id(COLPVT[:order])
	end
   } }
]
[["Skip song",:skip],["I Love this song!",:love],["Ban this song!",:ban]].each {|item| $menus<<{:menu=>:lastfm , :label=>item[0], :action => Proc.new {$player.lastfmcommand(item[1])} } }

# Built-in context action
$contextactions=[{ :label => "Visit related link", :verifyer=> Proc.new{ |s| s[COLMAP[:url]]!="" }, :action => Proc.new { |s| surf(s[COLMAP[:url]]) } },
	{ :label => "Delete selected from list", :verifyer=> Proc.new { |s| !$section[:protected] && $section[:file]}, :action => Proc.new {
		(data=open($section[:file],"r").collect).delete_at($songs.selection.selected[COLPVT[:lineno]]-1)
		open($section[:file],"w"){|f|data.each{|line| f.puts(line) } }
		setmode
	} }
]

# Built-in toolbar buttons
$toolbar=[{:id=>:refresh,:icon=>Gtk::Stock::REFRESH, :verifyer=>Proc.new {!$section[:onrefreshask] }, :action=>Proc.new{
	if  (!$section[:onrefreshask] || (dialog = Gtk::MessageDialog.new($window, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::QUESTION, Gtk::MessageDialog::BUTTONS_OK_CANCEL, $section[:onrefreshask])).run == Gtk::Dialog::RESPONSE_OK) then
  	Thread.new {
  			$statbar.push($statbar.get_context_id("indexer"),"Indexing #{$section[:label]}...")
  			$section[:onrefresh].call $section
  			$statbar.push($statbar.get_context_id("indexer"),"Indexed.")
  			setmode
  	}
	end
	dialog.destroy if defined?(dialog) && dialog!=nil
}},{:sep=>1},{:id=>:pause,:icon=>Gtk::Stock::MEDIA_PAUSE, :action=>Proc.new{$player.control(:pause,nil)}},{:id=>:stop,:icon=>Gtk::Stock::MEDIA_STOP, :action=>Proc.new{$player.control(:stop,:byhand)}},{:id=>:stop,:icon=>Gtk::Stock::MEDIA_REWIND, :action=>Proc.new{$player.control(:rewind,nil)}},{:id=>:stop,:icon=>Gtk::Stock::MEDIA_FORWARD, :action=>Proc.new{$player.control(:forward,nil)}},{:id=>:fullscreen,:icon=>Gtk::Stock::FULLSCREEN, :action=>Proc.new{$player.control(:fullscreen,nil)} },{:sep=>1}]

class Mplayer
	attr_accessor :state , :meta, :features, :voidmeta
	@@LASTFM={:login=>"http://ws.audioscrobbler.com/radio/handshake.php?version=1.1.1&platform=linux&username=%s&passwordmd5=%s&debug=0&partner=",:tune=>"http://ws.audioscrobbler.com/radio/adjust.php?session=%s&url=%s&debug=0",:info=>"http://ws.audioscrobbler.com/radio/np.php?session=%s&debug=0",:command=>"http://ws.audioscrobbler.com/radio/control.php?session=%s&command=%s&debug=0",}
  
	def resetmeta(metadata={}) @meta=voidmeta.merge(metadata) end
	def connect_meta(&blk) @action=blk end
	def connect_runtime(&blk) @runtime=blk end
	def connect_lastfmaction(&blk) @lastfmaction=blk end
  	def backgroundupdate; if @@LASTFM && @meta[:file][0..5]=="lastfm" && @lastfmdata[:session] && @meta[:title]!="" && ((@lc=(@lc+1)%1500)==0) then open(@@LASTFM[:info] % [ @lastfmdata[:session] ]) { |f| f.each { |line| {/^artist=(.*)/ => :artist, /^track=(.*)/ => :title,/^album=(.*)/ => :album,/^albumcover_small=(.*)/ => :cover,/^track_url=(.*)/ => :url}.each {|k,v| setmeta(v,(v==:cover && line[/\/noimage\//]? nil : line[k,1])) if line[k]} } } end end

=begin
	def initialize(lastfmuser="",lastfmpassword="")
	  @pipe, @thread, @action, @runtime, @lastfmaction, @lc, @features, @state, @lastfmdata, @voidmeta = nil, nil, nil, nil, nil, nil, {:formats=>[".mp3",".ogg"]}, [:stop,:byhand], {:session=>nil,:url=>nil,:user=>lastfmuser,:password=>lastfmpassword}, {:title=>$opt[:unknown], :artist=>$opt[:unknown], :album=>$opt[:unknown] }
		resetmeta
	end
=end

	def setmeta(v1=nil,v2=nil)
	    if v1 then oldmeta , @meta[v1] = @meta[v1] , v2 else @state=v2 end
		if @action && (!v1 || oldmeta!=v2) then @action.call self end  
	end
	
	def startup(file,metadata,indexonly)
		control(:stop,:byhand) if @state[0]!=:stop
		resetmeta(metadata.merge({:file=>file}))
		# Sleeping helps lastfm's np.php service to keep updated - probably waits that the last playback is fully closed server side.
		if @@LASTFM && @meta[:file][0..5]=="lastfm" && @lastfmdata[:user]!="" && sleep(1) then open(@@LASTFM[:login] % [ @lastfmdata[:user], Digest::MD5.hexdigest(@lastfmdata[:password]) ]) { |f| f.each { |line| {:session=>/^session=(.*)/,:url=>/^stream_url=(.*)/}.each{ |i,r|  @lastfmdata[i]=line[r,1] if line[r] } } } end 
	  if @@LASTFM && @meta[:file][0..5]=="lastfm" && @lastfmdata[:session] then open(@@LASTFM[:tune] % [ @lastfmdata[:session], file ]) { |f| f.each { |line| setmeta(:title,"LastFM: "+line[/^stationname=(.*)/,1].strip) if line[/^stationname=/]  }  } end
  	if !indexonly && @meta[:file].to_s[0..0]=="/" && (fname=Dir.new(File.dirname(@meta[:file])).select {|item| item[/cover/i] && (item[/\.jpg$/i] || item[/\.png$/i] || item[/\.bmp$/i])}.first) then setmeta(:cover,File.dirname(@meta[:file])+"/"+fname) end
		@lc=1450
	end
  
  # Using .. ranges for make it faster... is already full of regexps...
	def play(file,metadata={},indexonly=false)
	  startup(file,metadata,indexonly)
	  @pipe=IO.popen("#{indexonly ? "echo q|" : ""}mplayer "+(["asx","pls"].index(@meta[:file][-3..-1])?"-playlist":"")+" \""+(@meta[:file][0..5]=="lastfm" && @lastfmdata[:session] && @meta[:title]!=$opt[:unknown] ? @lastfmdata[:url] : @meta[:file])+"\" #{indexonly ? "-ao null -vo null" : ""} 2>&1",'r+')
		setmeta(nil,[:play,nil])
		@thread=Thread.new {
		  @pipe.each("\r") { |line|
		    backgroundupdate
			  {/^ Year: (.*)/=>:year,/^ Artist: (.*)/=>:artist,/^ Album: (.*)/=>:album,/StreamTitle='([^']*)';/=>:title,/^ Title: (.*)/=>:title,/^ Name: (.*)/=>:title,/^ Track: (.*)/=>:trackno}.each_pair { |tag,i| setmeta(i,line[tag,1].strip) if line[tag,1].to_s.strip.length>0 }
			  @runtime.call(line[/^[^\(]*\(([^\)]*)\)/,1],line[/ of [^\(]*\(([^\)]*)/,1],line[/:([^(]*)/,1].strip.to_f,line[/ of ([^(]*)/,1].strip.to_f) if @runtime && line[0..1]=="A:" && !line.include?("A-V")
      }
		  setmeta(nil,[:stop,@state[1]])
		}
	end

	def control(action,attr)
		setmeta(nil,[:stop,attr]) if action == :stop
		setmeta(nil,[(@state[0] == :play ? :pause : :play),attr]) if action==:pause && @state[0]!=:stop
		{:stop=>["q"],:pause=>["p"],:fullscreen=>["f"],:forward=>[27,91,67],:rewind=>[27,91,68]}[action].each { |c| @pipe.putc(c) } if @thread && @thread.alive?
		@thread.join if @state[0] == :stop && @thread && @thread.alive?
	end
	
	def lastfmcommand(cmd) 
	 if @@LASTFM && @lastfmdata[:session] && @meta[:file][0..5]=="lastfm" && @state[0]!=:stop then
    open(@@LASTFM[:command] % [ @lastfmdata[:session], cmd.to_s ]) { |f| f.each {|line| @lastfmaction.call(cmd,line[/^response=(.*)/,1].downcase) if line[/^response=/] && @lastfmaction } }
    play(@meta[:file]) if cmd==:skip || cmd==:ban
   end
  end
end

def surf(url) 
	fork {`google-chrome "#{url}"`} 
end  
def formatrecord(table,data=nil); 
	DATABASES[(data ? table : :file)].collect{|x| (data ? data : table)[x].to_s}.join($opt[:separator]) 
end
def unformatrecord(table,data=nil); 
	id, ret=-1,{}; (data ? data : table).rstrip.split($opt[:separator]).each{|x| ret[DATABASES[(data ? table : :file)][id+=1]]=x.rstrip }; ret 
end
def getcovername(artist,album) 
	$opt[:covers]+Digest::MD5.hexdigest(album+"|"+artist)
end
#def boxit(obj) Gtk::ScrolledWindow.new.add(obj).set_hscrollbar_policy(Gtk::PolicyType::AUTOMATIC) end
def boxit(obj)
	Gtk::ScrolledWindow.new.container.add(obj).set_hscrollbar_policy(Gtk::PolicyType::AUTOMATIC) 
end


def updatedatabase(section)
  databases={:artists=>[],:albums=>[],:file=>[]}
	Find.find(section[:root]) do |path|
		if !FileTest.directory?(path) && $player.features[:formats].index(File.extname(path).downcase)!=nil
			(data=Mplayer.new).play(path,{:title=>File.basename(path)},true).join			
			data.meta[:file]=path[section[:root].length..-1]
			databases.each_key { |k| databases[k] << formatrecord(k,data.meta) if databases[k].index(formatrecord(k,data.meta)) == nil }
		end
	end
	databases.each {|k,v| File.open(section[k],"w") { |f| (k==:file ? v : v.sort).each { |line| f.puts(line) } } }
end

def updateartists
	$artistslist.clear.append[0] , $curartist = $opt[:all] , $opt[:all]
	open($section[:artists], "r").each { |line| $artistslist.append[0]=unformatrecord(:artists,line)[:artist] } if File.exists?($section[:artists])
	$artists.selection.select_iter $artistslist.iter_first
	updatealbums
end

def updatealbums
  $entry , cache , $curalbum, $entry[0], $entry[1] = $albumslist.clear.append , [] , $opt[:all],$opt[:all],Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, false, 8, $opt[:coverboxw].to_i, $opt[:coverboxh].to_i).fill!(0x99aaaaff)  
	if File.exists?($section[:albums])
		open($section[:albums], "r").each { |line|
		  details = unformatrecord(:albums,line)
		  if ($curartist == $opt[:all] || details[:artist].chomp == $curartist ) && cache.index(details[:album])==nil
		    cache << details[:album]
        $entry, $entry[0] , $entry[1] = $albumslist.append, details[:album] , ($opt[:coverbox] && File.exist?(cfile=getcovername(details[:artist].chomp,details[:album])) ? Gdk::Pixbuf.new(cfile,$opt[:coverboxw].to_i, $opt[:coverboxh].to_i) : Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, false, 8, $opt[:coverboxw].to_i, $opt[:coverboxh].to_i).fill!(0xeeeeeeff) ) 
      end
	  }
	end
	$albums.selection.select_iter $albumslist.iter_first
	updatesongs
end

def updatesongs
	if $curartist != nil && $curalbum != nil
	  # Data is preloaded, since opening urls uses the Timeout object and can't
	  # be into an exclusive block.
		begin data=open($section[:file], "r").collect; rescue =>exp; end
		# Playlist update is done in exclusive mode
		Thread.exclusive {
  		$songslist.clear;$rowcount=(data ? data.length : 0 )
      if data then data.each_with_index { |line,rowcount|
			  details = unformatrecord(line)
			  if ((!$section[:artists]) || (($curartist == $opt[:all] || details[:artist] == $curartist ) && ($curalbum == $opt[:all] || details[:album] == $curalbum ))) && ($lookup.text=="" || ($opt[:columns].collect { |x| details[x].to_s }.join(" ").downcase.index($lookup.text.downcase))!= nil )
				 item, item[COLPVT[:lineno]]= $songslist.append, rowcount+1
				 COLMAP.each_pair{|a,b| item[b]=(NUMCOLS.index(a)==nil ? details[a] : details[a].to_i)}
			  end
		  } end
		}
	end
end

def makedatabase(section)
	cache=[]
	open(section[:file], "w") { |f| open(section[:backend],"r") { |data| data.each { |line|
			cache[0]=line[Regexp.compile(section[:rename]),1] if line[Regexp.compile(section[:rename]),1]
			cache[1]=section[:prefix].to_s+(section[:encodeurl] ? URI.escape(line[Regexp.compile(section[:redata]),1]) : line[Regexp.compile(section[:redata]),1] ) if line[Regexp.compile(section[:redata]),1]
			if cache.nitems==2
				f.puts(formatrecord({:title=>cache[0],:file=>cache[1]}))
				cache=[]
			end
	} }	}
end

def makedatabasepodcast(section,md5=false)
  $statbar.push($statbar.get_context_id("indexer"),"Updating #{section[:label]}...")
  open(section[:file],"w") { |f|
    curpos=0
    REXML::Document.new(open(section[:xml])).elements.each("//item") { |item|
      new_items = {}
      item.elements.each { |e| new_items[e.name.gsub(/^dc:(\w)/,"\1").to_sym] = (e.attribute("url") ? e.attribute("url").to_s : e.text) }
      f.puts(formatrecord({:artist=>new_items[:creator], :trackno=>curpos+=1, :title=>new_items[:title]+(new_items[:duration] ? " ("+new_items[:duration].to_s+")" : ""), :file=>new_items[:enclosure], :url=>new_items[:link]}))
    }
  }
  $statbar.push($statbar.get_context_id("indexer"),"#{section[:label]} updated.")
  Digest::MD5.hexdigest(File.read(section[:file])) if md5
end

def setmode(int=$section)
  Thread.exclusive {
	 $sectionlabel.markup, $lookup.text, $vp.position , $toolbaritems[:refresh].sensitive, $coverbox.visible = "<b>#{int[:label].to_s}</b>", "", (($arb.visible=$alb.visible=(($section=int)[:artists]!=nil)) ? $opt[:filterheight].to_i : 0) , $section[:onrefresh]!=nil , ($mainbox.position = ($arb.visible? && $opt[:coverbox] ? $opt[:coverboxheight].to_i : 0))>0
   $menulist.each { |idx| $menuentries[idx[:id]].visible=(!idx[:showif] || idx[:showif].call($section)) }
  } 	
  updatesongs if !$section[:onclick] || $section[:onclick].call($section)==:update
end

def getcover(artist,album,suggest="")
	cfile=suggest
	if (suggest=="" && (artist!=$opt[:unknown] && album!=$opt[:unknown])) || suggest!=""
		if !File.exist?(cfile=getcovername(artist,album))
			if (suggest=="") then begin open("http://www.amazon.com/s/ref=nb_ss_gw?url=search-alias%3Dpopular&field-keywords="+URI.escape(artist.to_s+" "+album.to_s)+"&x=0&y=0","r") { |data| data.each { |line| suggest=line[/img src=\"([^\"]*)"/,1] if line[/width=\"115\"/] && suggest=="" } }; rescue => error; puts "ERROR #{error}" end end
			if (suggest!="") then begin open(suggest,"r") { |fin| open(cfile, "w") { |fout| while (buf = fin.read(8192)) do fout.write buf end } }; rescue => error; end end
		end
	end
	(cfile && File.exist?(cfile) ? cfile : nil)
end

def notify(me)
	if me.state[0]!=:stop && $opt[:showcover] && ($covername=getcover(me.meta[:artist],me.meta[:album],me.meta[:cover])) then $cover.pixbuf,$smallcover.pixbuf=Gdk::Pixbuf.new($covername,$opt[:coverw].to_i,$opt[:coverh].to_i),Gdk::Pixbuf.new($covername,30,30) else $cover.file=$smallcover.file=$covername=nil end
	`purple-remote "setstatus?message=#{me.state[0]!=:stop ? URI.escape("(8) "+me.meta[:title].to_s+(me.meta[:artist]!=$opt[:unknown]?" - "+me.meta[:artist].to_s : "")) : "" }"` if $opt[:purple]
	n=Notify::Notification.new($window.title,"#{me.meta[:title]}\n#{me.meta[:artist]} - #{me.meta[:album]} #{me.state[0]==:pause ?" [PAUSED]" :""}",nil,$tray) if $notifies && me.state[0]==:play
	n.pixbuf_icon=Gdk::Pixbuf.new($covername,48,48) if $opt[:showcover] && $covername && $notifies && me.state[0]==:play
	n.show if $notifies && me.state[0]==:play
end

# Return true to confirm closing
# From is :fromwindow or :fromquit
def shutdown(from)
  $player.connect_meta {}
  $player.control(:stop,:byhand)
  `purple-remote "setstatus?message="` if $opt[:purple]
  $musicshare.shutdown if $musicshare
  Notify::uninit if $notifies
  true
end

def generateimplicits
	$lists.each_index { |i|
	  $lists[i][:protected], $lists[i][:icon], $lists[i][:onclick], $lists[i][:onrefreshask], $lists[i][:onrefresh] = true, "stock_folder", Proc.new { |s| updateartists; :norefresh}, "Do you want to refresh this music database?", Proc.new {|s| updatedatabase(s)} if $lists[i][:artists] && $lists[i][:albums]
    $lists[i][:icon], $lists[i][:onclick] = "stock_media-play", Proc.new { |s| makedatabase(s) if !File.exist?(s[:file]); :update} if $lists[i][:backend]
	  $lists[i][:icon],$lists[i][:protected],$lists[i][:file], $lists[i][:onrefresh], $lists[i][:onrefreshask] = "down",true,"#{$opt[:root]}/podcast_"+Digest::MD5.hexdigest($lists[i][:xml]), Proc.new {|s| makedatabasepodcast(s)}, "Do you want to update this podcast?" if $lists[i][:xml] && !$lists[i][:file]
	  $lists[i][:onclick]=Proc.new { :update } if !$lists[i][:onclick]
	}
end

def play(iter) if iter[COLMAP[:file]].to_s=="" && iter[COLMAP[:url]]!="" then surf(iter[COLMAP[:url]]) else $player.play($section[:root].to_s+iter[COLMAP[:file]],{:title=>(iter[COLMAP[:title]].to_s == "" ?  $opt[:unknown] : iter[COLMAP[:title]] ),:artist=>(iter[COLMAP[:artist]].to_s=="" ?  $opt[:unknown] : iter[COLMAP[:artist]]),:album=>(iter[COLMAP[:album]].to_s=="" ? $opt[:unknown] : iter[COLMAP[:album]] ), :cover=>iter[COLMAP[:cover]].to_s, :url=>iter[COLMAP[:url]].to_s, :custommeta=>iter[COLMAP[:custommeta]].to_s, :trackno=>iter[COLMAP[:trackno]].to_i, :year=>iter[COLMAP[:year]].to_i}) end; end

def nextsong
	 if  (it=$songs.selection.selected).next! then 
		$songs.selection.select_iter(it)
		$songs.row_activated(it.path,$songs.get_column(0))
	end
end

# Updatemodes is called in blocking mode so multiple calls are queued.
def updatemodes; Thread.exclusive { 
      $modeslist.clear
    	$lists.each_with_index { |item,i| if !item[:hidden] then
    	  nitem, nitem[0], nitem[3] =$modeslist.append, item[:label], i
    	  begin nitem[2]=(item[:icon].to_s[0..4]=="file:" ? Gdk::Pixbuf.new(item[:icon][5..-1],$opt[:iconsize].to_i,$opt[:iconsize].to_i) : Gtk::IconTheme.default.load_icon(item[:icon],$opt[:iconsize].to_i,Gtk::IconTheme::LOOKUP_GENERIC_FALLBACK)); rescue =>error; end 
    	end }
} end

[$opt[:root],$opt[:covers]].each { |dir| Dir.mkdir(dir) if !File.directory?(dir) }

# artists
($artists = Gtk::TreeView.new($artistslist = Gtk::ListStore.new(String))).signal_connect("cursor-changed") { |me|
	$curartist, $lookup.text =(me.selection.selected ? me.selection.selected[0] : $curartist ), ""
	updatealbums
}

$artists.append_column( Gtk::TreeViewColumn.new("Artist",Gtk::CellRendererText.new,:text=>0) )

# album
($albums = Gtk::TreeView.new($albumslist = Gtk::ListStore.new(String,Gdk::Pixbuf))).signal_connect("cursor-changed") { |me|
	$curalbum, $lookup.text =(me.selection.selected ? me.selection.selected[0] : $curalbum ), ""
	updatesongs
}
$albums.append_column(Gtk::TreeViewColumn.new("Album",Gtk::CellRendererText.new,:text=>0))

# coverbox
#($coverbox=Gtk::IconView.new($albumslist).set_text_column(0).set_pixbuf_column(1)).signal_connect("selection-changed") { |me| me.selected_each {|iconview,path| $curalbum,$lookup.text=$albumslist.get_iter(path)[0],"";updatesongs } }

# songlist
$songslist = Gtk::ListStore.new(String,String,String,Fixnum,Fixnum,String,String,String,String,Fixnum,Fixnum)
($songs = Gtk::TreeView.new($songslist).set_rules_hint(true)).signal_connect("row-activated") { |view, path, column| if iter = view.model.get_iter(path) then play(iter) end }
$opt[:columns].each { |name|
	$songs.append_column( (col=Gtk::TreeViewColumn.new(LABELS[name].to_s,renderer= Gtk::CellRendererText.new,:text=>COLMAP[name])).set_sort_column_id(COLMAP[name]))
	col.set_cell_data_func(renderer) { |col, renderer, model, iter| renderer.text="" if iter[COLMAP[name]]==0} if NUMCOLS.index(name)!=nil
}

# Popup menu
$songs.signal_connect("button_press_event") { |widget, event|
  if event.kind_of? Gdk::EventButton and event.button == 3 and $songs.selection.selected
	popup = Gtk::Menu.new
	# Custom context actions
	$contextactions.each_index { |i| if $contextactions[i][:verifyer].call($songs.selection.selected) then popup.append(itm=Gtk::MenuItem.new($contextactions[i][:label]));itm.signal_connect("activate") { $contextactions[i][:action].call($songs.selection.selected) } end }
	# Playlist handling actions
	$lists.select{|item| !item[:protected] && item[:file]}.each {|item| popup.append(itm=Gtk::MenuItem.new("Add to #{item[:label]}"));itm.signal_connect("activate") {open(item[:file],"a"){|f| f.puts(formatrecord(Hash[*Array.new(COLMAP.to_a).collect{ |x| [ x[0] , (x[0]==:file ? $section[:root].to_s : "")+$songs.selection.selected[x[1]].to_s]}.flatten]))}} }
    popup.show_all.popup(nil, nil, event.button, event.time)
  end
}

# mode
($modes = Gtk::TreeView.new($modeslist = Gtk::ListStore.new(String,Fixnum,Gdk::Pixbuf,Fixnum)).set_headers_visible(false)).append_column(Gtk::TreeViewColumn.new("",Gtk::CellRendererPixbuf.new,:pixbuf=>2))
$modes.append_column(Gtk::TreeViewColumn.new("Source",renderer=Gtk::CellRendererText.new,:text=>0))
$modes.columns[1].set_cell_data_func(renderer) { |col, renderer, model, iter| renderer.background=(iter[1]==1 ? "green" : nil) }
$modes.signal_connect("cursor-changed") { |me| setmode($lists[me.selection.selected.set_value(1,0).get_value(3)]) if me.selection.selected }

($window = Gtk::Window.new).signal_connect("destroy") { Gtk.main_quit }
#$window.set_title("Ruby Media Player").add(body=Gtk::Box.new(:vertical, 1)).set_default_size($opt[:width].to_i, $opt[:height].to_i).signal_connect('delete_event') { !shutdown(:fromwindow) }
$window.set_title("Ruby Media Player").add(body=Gtk::Box.new(:vertical, 1)) { !shutdown(:fromwindow) }
#body.pack_start(menubar = Gtk::MenuBar.new, :expand => false, :fill => false, :padding => 0).pack_start($toolBar = Gtk::Toolbar.new, :expand => false, :fill => false, :padding => 0).pack_end(($statbar=Gtk::Statusbar.new).pack_end($progress=Gtk::ProgressBar.new, :expand => false, :fill => false, :padding => 0), :expand => false, :fill => true, :padding => 0) << (($mainbox=Gtk::Paned.new(:vertical)) << boxit($coverbox).set_policy(Gtk::PolicyType::NEVER,Gtk::PolicyType::AUTOMATIC)) << (Gtk::Paned.new(:horizontal) << (side=Gtk::Box.new(:vertical,5).pack_end($cover = Gtk::Image.new, :expand => false, :fill => false, :padding => 0) << boxit($modes).set_policy(Gtk::PolicyType::NEVER,Gtk::PolicyType::AUTOMATIC)) << (($vp=Gtk::Paned.new(:vertical)) << (Gtk::Box.new(:horizontal,5) << ($arb=boxit($artists).set_policy(Gtk::PolicyType::NEVER,Gtk::PolicyType::AUTOMATIC)) << ($alb=boxit($albums).set_policy(Gtk::PolicyType::NEVER,Gtk::PolicyType::AUTOMATIC))) << (Gtk::Box.new(:vertical,5).pack_start((Gtk::Box.new(:horizontal,5).set_border_width(1).pack_start($sectionlabel=Gtk::Label.new, :expand => false, :fill => true, :padding => 0).pack_start(Gtk::Label.new, :expand => true, :fill => true, :padding => 0).pack_start(Gtk::Label.new("Search"), :expand => false, :fill=> true, :padding => 0).pack_start($lookup=Gtk::Entry.new, :expand => false, :fill => false, :padding => 0)), :expand => false, :fill => false, :padding => 0) << boxit($songs).set_policy(Gtk::PolicyType::NEVER,Gtk::PolicyType::AUTOMATIC))))
body.pack_start(menubar = Gtk::MenuBar.new, :expand => false, :fill => false, :padding => 0).pack_start($toolBar = Gtk::Toolbar.new, :expand => false, :fill => false, :padding => 0).pack_end(($statbar=Gtk::Statusbar.new).pack_end($progress=Gtk::ProgressBar.new, :expand => false, :fill => false, :padding => 0), :expand => false, :fill => true, :padding => 0) << (($mainbox=Gtk::Paned.new(:vertical)) << boxit($coverbox)) << (Gtk::Paned.new(:horizontal) << (side=Gtk::Box.new(:vertical,5).pack_end($cover = Gtk::Image.new, :expand => false, :fill => false, :padding => 0) << boxit($modes)) << (($vp=Gtk::Paned.new(:vertical)) << (Gtk::Box.new(:horizontal,5) << ($arb=boxit($artists)) << ($alb=boxit($albums))) << (Gtk::Box.new(:vertical,5).pack_start((Gtk::Box.new(:horizontal,5).set_border_width(1).pack_start($sectionlabel=Gtk::Label.new, :expand => false, :fill => true, :padding => 0).pack_start(Gtk::Label.new, :expand => true, :fill => true, :padding => 0).pack_start(Gtk::Label.new("Search"), :expand => false, :fill=> true, :padding => 0).pack_start($lookup=Gtk::Entry.new, :expand => false, :fill => false, :padding => 0)), :expand => false, :fill => false, :padding => 0) << boxit($songs))))


($tray=Gtk::StatusIcon.new.set_stock(Gtk::Stock::MEDIA_PLAY)).signal_connect("activate") { ($window.visible? ? $window.hide : $window.show) }
["insert_text","delete-from-cursor","backspace"].each { |m| $lookup.signal_connect(m) { if $lookupthread then $lookupthread.kill end; $lookupthread=Thread.new { sleep 1; updatesongs; $lookupthread=nil } } }

Notify::init($window.title) if $notifies
$window.show_all

# Now everything is ready and can be overloaded/overwritten/updated. Loads plugin into the plugin folder
if File.directory?($opt[:plugins]) 
	then ($opt[:loadplugins] && $opt[:loadplugins].length>0 ? $opt[:loadplugins] : Dir.new($opt[:plugins])).each { |f| require($opt[:plugins]+"/"+f) if f[0..7]=="kplugin_" && File.extname(f)==".rb"} 
end

# Initializing all structures
$player, $menuentries, menu, $rowcount, $toolbaritems, $covername = Mplayer.new($opt[:lastfmuser], $opt[:lastfmpass]), {}, {} , 0, {}, nil
$player.connect_runtime { |current,length,perc,tot| $progress.set_text("#{current} of #{length}").set_fraction((tot>0 ? perc/tot : 0)) }
$player.connect_lastfmaction { |action,result| $statbar.push($statbar.get_context_id("lastfm"),"#{action.to_s.capitalize} #{result=="ok" ? "done." : "gone wrong."}")}
$player.connect_meta { |me|
	if $notifythread then $notifythread.kill end
       	if me.state[0]==:stop then $progress.text, $progress.fraction , $label.text = "" , 0 , "Stopped." else $label.markup="<b>#{me.meta[:title]}</b>\nby <i>#{me.meta[:artist]}</i> from <i>#{me.meta[:album]}</i>#{me.state[0]==:pause ?" [PAUSED]" :""}" end 
	if me.state[0]==:stop && me.state[1] != :byhand then nextsong end
	$tray.tooltip, $notifythread = $window.title+"\n"+$label.text, Thread.new { sleep 4; notify(me) }
}

# Reads custom entries
#if File.exist?($opt[:settings]) && (configdata=YAML::load_file($opt[:settings])) && configdata[:lists] then $lists.concat(configdata[:lists]).collect { |item| item.each_key { |k| item[k].gsub!(/\{[^}]*\}/) { |pattern| ENV[pattern[1..-2]] } if item[k].class==String } } end
# Generate implicit methods for builtin lists kinds
#generateimplicits
# Create menus
#$menulist.each{|menuitem| menubar.append( ($menuentries[menuitem[:id]]=Gtk::MenuItem.new(menuitem[:label])).set_visible(true).set_submenu( (menu[menuitem[:id]]=Gtk::Menu.new).set_visible(true) ) ) }
#$menus.each_index { |idx| menu[$menus[idx][:menu]].append(itm=Gtk::MenuItem.new( $menus[idx][:label] ).set_visible(true));itm.signal_connect("activate") {$menus[idx][:action].call} }
# Create the toolbar
#$toolbar.each {|i| if i[:sep] then $toolBar.append(Gtk::SeparatorToolItem.new.set_visible(true)) else $toolBar.append($toolbaritems[i[:id]]=Gtk::ToolButton.new(i[:icon])).set_visible(true).signal_connect("clicked") {i[:action].call} end }
#$toolBar.append(Gtk::Box.new(:horizontal,5).set_border_width(5)<< ($smallcover = Gtk::Image.new) << ($label=Gtk::Label.new("Stopped.") )).show_all
# Update the modes list
#updatemodes

#setmode($lists[0])

Gtk.main
