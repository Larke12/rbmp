# rbmp -- Ruby Media Player

Inspired by KesieV Chiefs, a Ruby Media Player in 300 lines of code.

## Purpose

The main purpose of RBMP is to create a GTK3 Media Player and give the GNU/Linux and POSIX compliant user access to their iTunes Library XML file. This means that you could access the same music and playlists from Linux. This application will be designed following the new [X-App guidelines](http://segfault.linuxmint.com/2016/02/the-first-two-x-apps-are-ready/).

## Running

`ruby rbmp.rb`

## Credits & Dependencies

This application currently requires the following gems 

`gem install gtk3`

## Other Notes
- [GTK+ Developer Docs](https://developer.gnome.org/gtk3/3.16/)
- [Ruby/GNOME2 Bindings](https://github.com/ruby-gnome2/ruby-gnome2)
- [Using .glade with Ruby](http://stackoverflow.com/questions/32116885/ruby-gtk-app-done-correctly)
- [Using Glade .xml with Ruby](https://gist.github.com/gpr/3512c3e66022249c833f)
- [iTunes Library File Format](http://fileformats.archiveteam.org/wiki/ITunes_Music_Library)
- [Apple's Developer Noted on XML](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PropertyLists/UnderstandXMLPlist/UnderstandXMLPlist.html)
