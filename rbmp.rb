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

builder = Gtk::Builder.new
builder.add_from_file("rbmp.glade")
builder.connect_signals {|handler| method(handler) }

Gtk.main
