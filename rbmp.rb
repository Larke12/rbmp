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

# Store location of glade file
builder_file = "rbmp.ui"

# Construct the builder instance and load the UI description
builder = Gtk::Builder.new(:file => builder_file)

window = builder.get_object("window")
window.signal_connect("destroy") { Gtk.main_quit }

Gtk.main
