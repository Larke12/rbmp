=begin

 AUTHOR:
  Kesiev <http://www.kesiev.com>
  
 WHAT IT DOES:
  Uses the "no album" image from LastFM as unknown album image, that is
  better than the empty block into the cover browser and nothing into the
  GUI. It overloads the getcovername and the getcover method. This plugin is
  quite simple but I've added some comments that can be useful for creating
  more cover backends.

=end

# Let's serve a common filename when asking for unknow artist or album's song.
# If an artist name and an album name is provided, it asks to the original
# getcovername function the right name. In this way we don't use a million of
# identical files for missing cover entries.
alias missingcover_getcovername getcovername
def getcovername(artist,album)
  if artist==$opt[:unknown] || album==$opt[:unknown] then
    $opt[:covers]+"noimage"
  else
    missingcover_getcovername(artist,album)
  end
end

# When asked to show a cover, we will serve the "noimage" url from LastFM to the
# original getcover function: it will download the cover and put it into the
# "getcovername" filename (which will be the "noimage" file).
# The original getcover has a sort of caching so the cover file will be
# downloaded once.
alias missingcover_getcover getcover
def getcover(artist,album,suggest=nil)
  if artist==$opt[:unknown] || album==$opt[:unknown] then
    suggest="http://cdn.last.fm/depth/catalogue/noimage/cover_130.png"
  end
  missingcover_getcover(artist,album,suggest)
end