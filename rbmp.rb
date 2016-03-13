#!/usr/bin/ruby

require 'gtk3'
#require 'find'
#require 'open-uri'
#require 'digest/md5'
#require 'webrick'
#require 'rexml/document'
#require 'yaml'
#require 'nokogiri'
#require 'gir_ffi'

begin $notifies=require 'rnotify'; rescue LoadError; end

class RBMP_gui
	def initialize
		if __FILE__ == $0
			# Construct the builder instance and load the UI description
			@builder = Gtk::Builder.new
			@builder.add_from_file('rbmp.glade')
			@builder.connect_signals{|handler| method(handler)}
			Gtk.main()
		end
	end

	# Connect About Dialog to menu button
	def on_menu_about_activate
		p "Now open the window!"
	end
	
	# Play button debug
	def on_play_butt_clicked
		p "Play a song!"
	end

	# Self explanatory exit
	def gtk_main_quit
		puts "Gtk.main_quit"
		Gtk.main_quit()
	end
end

RBMP_gui.new
