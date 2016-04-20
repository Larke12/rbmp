#!/usr/bin/ruby

require 'gtk3'

begin $notifies=require 'rnotify'; rescue LoadError; end

# Construct the builder instance and load the UI description
builder = Gtk::Builder.new
builder.add_from_file('rbmp.glade')
builder.connect_signals{|handler| method(handler)}

# Link the main window to the quit event
window = builder.get_object("window")
window.signal_connect("delete-event") { Gtk.main_quit }

quit = builder.get_object("quit")
quit.signal_connect "activate" do
	Gtk.main_quit
end

# Initialize Dialogs
open_file_dial = builder.get_object("open_file_dial")
about_dial = builder.get_object("about_dial")

# Initialize List and Tree stores
tree_store = builder.get_object("tree_store") # Side bar: sections
list_store = builder.get_object("list_store") # Main box: songs

# Initialize Tree views
tree_view = builder.get_object("tree_view")
song_view = builder.get_object("song_view")

# Connect Open File Dialog to open button
open_dial = builder.get_object("open_dial")
open_dial.signal_connect "activate" do
	open_file_dial.run
end

# Connect About Dialog to menu button
menu_about = builder.get_object("menu_about")
menu_about.signal_connect "activate" do
	about_dial.run
end

# Connect About Dialog button box to buttons
about_button_box = builder.get_object("about_button_box")
close_butt = Gtk::Button.new(:label => "Close")
about_button_box.add(close_butt)
close_butt.signal_connect "activate"  do
	about_dial.destroy
end

# Populate Tree view
# http://python-gtk-3-tutorial.readthedocs.org/en/latest/treeview.html
# iter = tree_store.append(nil) -- Already populated modeled
renderer = Gtk::CellRendererText.new

renderer = Gtk::CellRendererText.new
column = Gtk::TreeViewColumn.new("Library", renderer, {
	:text => 0,
})
tree_view.append_column(column)

# Parse XML to list_store


# Populate List view


# Play button debug
play_butt = builder.get_object("play_butt")
play_butt.signal_connect "clicked" do
	p "Play a song!"
end

Gtk.main
