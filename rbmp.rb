#!/usr/bin/ruby

require 'gtk3'
require 'nokogiri'

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
model = Gtk::TreeStore.new(String)

iter = model.append(nil)
iter[0] = "Artists"
iter = model.append(nil)
iter[0] = "Albums"
iter = model.append(nil)
iter[0] = "Songs"

tree_view.set_model(model)

renderer = Gtk::CellRendererText.new
column = Gtk::TreeViewColumn.new("Library", renderer, {
	:text => 0,
})

tree_view.append_column(column)

# Parse XML file
# https://goo.gl/tPaQ8R
list = []
data_file = "~/Music/iTunes/iTunes\ Music\ Library.xml"
@doc = File.open(File.expand_path(data_file)) { |f| Nokogiri::XML(f) }

# Find each dictionary item and loop through it
@doc.xpath('/plist/dict/dict/dict').each do |node|
	hash     = {}
	last_key = nil

	# Stuff the key value pairs in to hash.  We know a key is followed by
	# a value, so we'll just skip blank nodes, save the key, then when we
	# find the value, add it to the hash
	node.children.each do |child|
		next if child.blank?

		if child.name == 'key'
			# Save off the key
			last_key = child.text
		else
			# Use the key we saved
			hash[last_key] = child.text
		end
	end
	list << hash # push on to our list
end

# Populate List view
# Name, Artist, Album
model = Gtk::ListStore.new(String, String, String)

list.each do |key, array|
	# Parse each hash
	model.append.set_values([key["Name"], key["Artist"], key["Album"]])
end	

song_view.set_model(model)

renderer = Gtk::CellRendererText.new
column = Gtk::TreeViewColumn.new("Name", renderer, {
	:text => 0,
})

song_view.append_column(column)

renderer = Gtk::CellRendererText.new
column = Gtk::TreeViewColumn.new("Artist", renderer, {
	:text => 1,
})

song_view.append_column(column)

renderer = Gtk::CellRendererText.new
column = Gtk::TreeViewColumn.new("Album", renderer, {
	:text => 2,
})

song_view.append_column(column)

# Play button 
play_butt = builder.get_object("play_butt")
image = Gtk::Image.new
label = Gtk::Label.new
play_butt.signal_connect "clicked" do
	# play selected song
	stock_name = "Gtk::Stock::MEDIA_STOP"
	label.set_text("Stop")
	image.set_stock(eval(stock_name))
	#system('mpv --no-audio-display ~/Music/iTunes/iTunes\ Media/Music/Makoto\ Miyazaki/ONE\ PUNCH\ MAN\ ORIGINAL\ SOUNDTRACK\ \(ONE\ T/11\ Sonic.m4a &')
end


Gtk.main
