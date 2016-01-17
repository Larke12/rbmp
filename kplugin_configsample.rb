=begin

 AUTHOR:
  Kesiev <http://www.kesiev.com>

 WHAT IT DOES:
  Dumps the default options and lists of KesieV Chiefs. It shows the structure
  and how the default lists are built for creating your custom derived playlists.
  Note that using the outputed config file makes duplicates of the default
  playlist: the ":lists" section is meant to be used for copy-paste stuff.
  
 NOTES:
  Use it as the only loaded plugin for a cleaner config file.
  
=end

alias configsample_generateimplicits generateimplicits 
def generateimplicits
  puts "--- SAMPLE YAML FILE ---\n\n"
  puts ({:opt=>$opt,:lists=>$lists}.to_yaml)
  puts "\n\n---"
  configsample_generateimplicits
end
