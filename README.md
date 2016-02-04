# rbmp -- Ruby Media Player

Based off of KesieV Chiefs, a Ruby Media Player in 300 lines of code.

## Purpose

The main idea behind rbmp is to update the GUI to GTK3 and give the GNU/Linux and POSIX compliant user access to their iTunes Library XML file. This means that you could access the same music, playlists, and update that same information from Linux. This application will be designed following the new [X-App guidelines](http://segfault.linuxmint.com/2016/02/the-first-two-x-apps-are-ready/).

## Running

The original program can be run (with Ruby GTK2) via

`ruby kesievchiefs-0.4.rb`

## Credits & Dependencies

For now, check the [original website](http://www.kesiev.com/kesievchiefs/).

## Other Notes
- [Using .glade with Ruby](http://stackoverflow.com/questions/32116885/ruby-gtk-app-done-correctly)
- [Using Glade .xml with Ruby](https://gist.github.com/gpr/3512c3e66022249c833f)
- [iTunes Library File Format](http://fileformats.archiveteam.org/wiki/ITunes_Music_Library)
- [Apple's Developer Noted on XML](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PropertyLists/UnderstandXMLPlist/UnderstandXMLPlist.html)