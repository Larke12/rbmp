=begin

 AUTHOR:
  Kesiev <http://www.kesiev.com>
  
 WHAT IT DOES:
  Simple flexible settings dialog. Suggested by Xavi.

=end

# Get the plugin's file name
$settings_plugnname=File.basename(__FILE__)

# Entries to be hidden
$settings_hide=[:separator,:settings,:loadplugins,:plugins,:root,:covers,:all,:unknown,:columns]

# Playlist templates
$settings_templates=[
	{
		:label=>"Static playlist",
		:content=>{
			:label=>"New playlist",
			:file=>"{HOME}/.kesievchiefs/changeme",
			:icon=>"apple-red"
		}
	},
	{
		:label=>"Shared music",
		:content=>{
			:label => "New share source",
			:root => "http://<ip of remote server>:12345/",
			:file => "http://<ip of remote server>:12345/songs",
			:protected => true,
			:icon => "connect_established"
  		}
	},
	{
		:label=>"Podcast",
		:content=>{
			:label=>"New podcast",
			:xml=>"http://feeds.feedburner.com/amplified"
		
		}
	},
	{
		:label=>"Parsed playlist",
		:content=>{
			:label=>"New parsed playlist",
			:file=>"{HOME}/.kesievchiefs/changeme",
			:rename=>"Regular expression for entry name",
			:redata=>"Regular expression for entry URL",
			:backend=>"URL of the page to be parsed",
			:encodeurl=>false
		}
	},
	{
		:label=>"Music database",
		:content=>{
			:label=>"New music database",
			:file=>"{HOME}/.kesievchiefs/changeme",
			:root=>"Put here your music directory",
			:artists=>"{HOME}/.kesievchiefs/changeme-artists",
			:albums=>"{HOME}/.kesievchiefs/changeme-albums"
		}
	},
	{
		:label=>"PLUGIN: Filesystem folder",
		:content=>{
			:label=>"New filesystem folder",
			:filesystem=>"Your music directory"
		}
	}
]

# Settings tabs
$settings_pages= [
	{
		:label => "Music",
		:items => [:musicroot]
	},
	{
		:label => "Interface",
		:items => [:height,:width,:iconsize,:defaultentries,:filterheight]
	},
	{
		:label => "Columns",
		:items => :columns
	},
	{
		:label => "Covers",
		:items => [:coverbox,:coverboxheight,:coverboxh,:coverboxw,:showcover,:coverh,:coverw]
	},
	{
		:label => "LastFM",
		:items => [:lastfmuser,:lastfmpass]
	},
	{
		:label => "Purple",
		:items => [:purple]
	},
	{
		:label => "Music sharing",
		:items => [:serverport]
	},
	{
		:label => "More",
		:items => :others
	},
	{
		:label => "Playlists",
		:items => :lists
	}	,
	{
		:label => "Plugins",
		:items => :plugins
	}	
]

# Settings labels and details
$settings_details={
# Plugins settings
	# hidewindow plugin
	:hidegreeting => {
		:label => "Hide the \"I'm here\" popup on start.",
	},
	# magnatune plugin
	:hidemagnatunenotifies => {
		:label => "Hide the \"Remember to buy\" popup on Magnatune."
	},
# Core settings
	:iconsize => {
		:label => "Size of icons in playlist",
	},
	:serverport => {
		:label => "Server port",
	},
	:coverboxheight => {
		:label => "Default height of the coverbox",
	},
	:purple => {
		:label => "Update purple-based status messages while playing (i.e. Pidgin)"
	},
	:coverbox => {
		:label => "Show coverbox"
	},
	:showcover => {
		:label => "Show covers during playback"
	},
	:filterheight => {
		:label => "Default height of the filter box",
		:notes => "Use 0 to hide the filter box"
	},
	:defaultentries => {
		:label => "Add built-in entries to the playlists"
	},
	:width => {
		:label => "Width of the window"
	},
	:height => {
		:label => "Height of the window"
	},
	:coverboxh => {
		:label => "Height of covers in coverbox"
	},
	:coverboxw => {
		:label => "Width of covers in coverbox"
	},
	:coverh => {
		:label => "Height of the cover under playlists"
	},
	:coverw => {
		:label => "Width of the cover under playlists"
	},
	:musicroot => {
		:label => "Music directory",
		# directory selector
		:directory=>true,
		# force trailing char before saving
		:trailing=>"/"
	},
	:lastfmuser => {
		:label => "Username"
	},
	:lastfmpass => {
		:label => "Password",
		# password box
		:password => true,
		:notes => "The password is saved in clear."
	},
	:columns => { 
		:label => "Columns in view"
	},
	:remoteport => { 
		:label => "Port for remote control"
	}
}

# Add the settings entry before the quit option in the file menu
$menus.insert($menus.index{|x|x[:label]=="Quit" && x[:menu]==:file},
	{
		:menu=>:file, 
		:label=>"Settings",
		:action=>Proc.new{ settings_open }
	}
)

# "installs" the plugin
def settings_install

	configfile=nil
	
	# Load the config file if exists
	if File.exist?($opt[:settings]) then configfile=YAML::load_file($opt[:settings]) end
	
	# Check if the config file is valid
	if configfile==nil || configfile==false then configfile={} end
	
	# Creates the "opt" section if not found
	if configfile[:opt]==nil then configfile[:opt]={} end

	# Creates the "opt->loadplugins" section if not found
	if configfile[:opt][:loadplugins]==nil then configfile[:opt][:loadplugins]=[] end

	# Removes the settings plugin if misplaced (not the last entry)
	configfile[:opt][:loadplugins].delete($settings_plugnname)
	
	# Appends the settings plugin at last
	if configfile[:opt][:loadplugins][configfile[:opt][:loadplugins].length-1]!=$settings_plugnname then
		configfile[:opt][:loadplugins]<<$settings_plugnname
	end
	
	# Save the file
	open($opt[:settings],"w"){|f| f.puts(configfile.to_yaml) }

end

# update the playlists dialog
def settings_updateplaylists
	$settings_listslist.clear
	$settings_lists.each_with_index { |entry,i|
		new=$settings_listslist.append
		new[0]=entry[:label]
		new[1]=i
	}
end

def settings_label(obj)
	Gtk::HBox.new(false).pack_start(obj,false,true)
end

def settings_save

	# Plain values

	$settings_values.each_pair { |key,obj|
	
		if $settings_config[:opt][key].class==Fixnum then
		
			# Numbers (handled by spinners)
			
			$settings_config[:opt][key]=obj.value.to_i
			
		elsif $settings_config[:opt][key].class==TrueClass || $settings_config[:opt][key].class==FalseClass  then
			
			# Boolean (handled by checkboxes)
			
			$settings_config[:opt][key]=obj.active?
			
		elsif $settings_config[:opt][key].class==Array  then

			# Arrays (handled by comma separated entries)

			$settings_config[:opt][key]=obj.text.split(",")

		elsif $settings_config[:opt][key].class==String  then
		
			# Strings (handled by entries)

			$settings_config[:opt][key]=obj.text
						
		end
		
		# Add trailing chars if specified in fields details
		
		if ($settings_details[key][:trailing]!=nil) then
			if $settings_config[:opt][key][-$settings_details[key][:trailing].length,$settings_config[:opt][key].length]!=$settings_details[key][:trailing] then
				$settings_config[:opt][key]+=$settings_details[key][:trailing]
			end
		end		
		
	}
	
	# columns editor
	
	$settings_config[:opt][:columns]=[]
	iter=$settings_columnslist.iter_first
	$settings_columnslist.each { |mode,path,iter|
		$settings_config[:opt][:columns] << iter[0].intern
	}
	
	# plugins editor
	
	$settings_config[:opt][:loadplugins]=[]
	iter=$settings_pluginslist.iter_first
	$settings_pluginslist.each { |mode,path,iter|
		$settings_config[:opt][:loadplugins] << iter[0]
	}
	# set himself as the last loaded plugin (was hiddend from the editor)
	$settings_config[:opt][:loadplugins] << $settings_plugnname
	
	# playlist editor

	$settings_config[:lists]=[]
	$settings_config[:lists].concat($settings_lists.compact)
	
	# Save the file
	
	open($opt[:settings],"w"){|f| f.puts($settings_config.to_yaml) }
	
end

def settings_savelistdata
	if $settings_listselected!=-1 then
		$settings_listvalues.each_pair { |key,value|
			if $settings_lists[$settings_listselected][key].class==TrueClass || $settings_lists[$settings_listselected][key].class==FalseClass then
				$settings_lists[$settings_listselected][key]=value.active?
			else
				$settings_lists[$settings_listselected][key]=value.text
			end
			if key==:label then
				$settings_listslist.each { |mode,path,iter|
					if iter[1]==$settings_listselected then iter[0]=value.text end
				}
			end
			
		}
	end
end

def settings_open
	# check if the plugin was the last loaded plugin
	if ($opt[:loadplugins]==nil || $opt[:loadplugins].length==0 || $opt[:loadplugins][$opt[:loadplugins].length-1]!=$settings_plugnname) then
		message="The plugin #{$settings_plugnname} have to be the last loaded plugin to work correctly and do not works if the :loadplugins: section is empty (i.e. autoload behaviour)\n"
		message << "Do you want to correct your config file?"
		if (dialog=Gtk::MessageDialog.new($window, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::ERROR, Gtk::MessageDialog::BUTTONS_YES_NO, message)).run==Gtk::Dialog::RESPONSE_YES then
			settings_install
			dialog.destroy
			(dialog=Gtk::MessageDialog.new($window, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::INFO, Gtk::MessageDialog::BUTTONS_OK, "Your config file should be OK now. Restart #{$window.title} to enable the settings dialog.")).run
			dialog.destroy
		else			
			dialog.destroy
		end
	else


		# latest selected item into the playlist editor
		$settings_listselected=-1
		
		# Settings controls
		$settings_values={}

		# Snapshot of the current configuration
		$settings_config={}
		
		# Snapshot of the config file (so playlists are fresh and untouched by plugins)
		if File.exist?($opt[:settings]) then $settings_config=YAML::load_file($opt[:settings]) end
		
		# Create the opt and lists sections, if not found
		if $settings_config[:opt]==nil then $settings_config[:opt]={} end
		if $settings_config[:lists]==nil then $settings_config[:lists]=[] end
		
		# Apply defaults from current session for options
		$opt.each_pair { |key,value| if $settings_config[:opt][key]==nil then  $settings_config[:opt][key]=$opt[key] end }
		
		# Snapshot of the current configured lists
		$settings_lists=[]
		$settings_lists.concat($settings_config[:lists])
		
		# list of all plugins
		plugins=[]
		Dir.new($opt[:plugins]).each { |f| plugins.push(f) if f[0..7]=="kplugin_" && File.extname(f)==".rb"} 
		# the settings plugin handles himself, loading as last item
		plugins.delete($settings_plugnname)
		
		# loaded plugins
		loaded_plugins=[]
		loaded_plugins.concat($settings_config[:opt][:loadplugins])
		# the settings plugin handles himself, loading as last item
		loaded_plugins.delete($settings_plugnname)
		
		# Available columns
		columns=[]
		LABELS.each_key { |item| columns << item.to_s }
		
		# Selected columns
		loaded_columns=[]
		$settings_config[:opt][:columns].each { |item| loaded_columns << item.to_s }
		
		# Index of all the available configuration keys (for calculating the "More" keys
		allitems=[]
		$settings_config[:opt].each_key { |key| allitems << key }
		$settings_hide.each { |key| allitems.delete(key) }
		
		$settings_window = Gtk::Window.new
		$settings_window.border_width = 5
		$settings_window.modal=true
		$settings_window.title="Settings"
		$settings_window.set_default_size(400,400)
		
		$settings_window.add(vbox=Gtk::VBox.new(false,5))
		
		vbox.pack_start(nbook=Gtk::Notebook.new)
		
		vbox.pack_start(buttonbox=Gtk::HBox.new,false,true)
		buttonbox.pack_start(Gtk::Label.new,true,true)
		buttonbox.pack_start(savebutton=Gtk::Button.new("Save",false),false,false)
		
		savebutton.signal_connect("clicked") {
			# apply the latest modifies to the playlist editor
			settings_savelistdata
			
			# save the settings file
			settings_save
			
			# warn the user to restart kesievchiefs
			(dialog=Gtk::MessageDialog.new($settings_window, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::WARNING, Gtk::MessageDialog::BUTTONS_OK, "Restart #{$window.title} for making the changes effective.")).run
			dialog.destroy
			$settings_window.destroy
		}
		
		$settings_pages.each { |page|

			if page[:items]==:plugins then
			
					vbox=Gtk::VBox.new(false,5)
					vbox.border_width=5
					
					vbox.pack_start(settings_label(Gtk::Label.new("Double click an item on available plugins to install it.\nDouble click a plugin on installed plugins to remove it.\nThe load process of plugins is ordered.")),false,true)

					nbook.append_page(vbox,Gtk::Label.new(page[:label]))
					
					mbox=Gtk::HBox.new(true)
					vbox.pack_start(mbox,true, true)
					
					$settings_plugins = Gtk::TreeView.new($settings_pluginslist = Gtk::ListStore.new(String))
					$settings_plugins.append_column( Gtk::TreeViewColumn.new("Installed",Gtk::CellRendererText.new,:text=>0) )
					$settings_plugins.signal_connect("row-activated") { |view, path, column| 
						if iter = view.model.get_iter(path) then
							$settings_availpluginslist.append[0]=iter[0]
							$settings_pluginslist.remove(iter)
						end
					}
					
					loaded_plugins.each { |key|
						$settings_pluginslist.append[0]=key
						plugins.delete(key)
					}
					
					mbox.pack_start(boxit($settings_plugins),true,true)

					$settings_availplugins = Gtk::TreeView.new($settings_availpluginslist = Gtk::ListStore.new(String))
					$settings_availplugins.append_column( Gtk::TreeViewColumn.new("Available",Gtk::CellRendererText.new,:text=>0) )

					plugins.each { |key|
						$settings_availpluginslist.append[0]=key
					}

					$settings_availplugins.signal_connect("row-activated") { |view, path, column| 
						if iter = view.model.get_iter(path) then
							$settings_pluginslist.append[0]=iter[0]
							$settings_availpluginslist.remove(iter)
						end
					}

					mbox.pack_start(boxit($settings_availplugins),true,true)

			elsif page[:items]==:lists then


				vbox=Gtk::VBox.new(false,5)
				vbox.border_width=5
				nbook.append_page(vbox,Gtk::Label.new(page[:label]))

				vbox.pack_start(settings_label(Gtk::Label.new("Click on a playlist to show the editor.")),false,true)

				vbox.pack_start(items_hbox=Gtk::HBox.new(true,5),true,true)
				
				$settings_listsbox = Gtk::TreeView.new($settings_listslist = Gtk::ListStore.new(String,Fixnum))
				$settings_listsbox.append_column( Gtk::TreeViewColumn.new("Playlists",Gtk::CellRendererText.new,:text=>0) )

				$settings_listsbox.signal_connect("cursor-changed") { |me|
					# Saves the latest fields modifies
					settings_savelistdata
					# Change the editor
					selecteditem =(me.selection.selected ? me.selection.selected[1] : -1 )
					if (selecteditem!=-1) then
						items_hbox.remove($settings_settingsbox) if $settings_settingsbox!=nil
						$settings_settingsbox=Gtk::VBox.new(false,5)
						$settings_settingsbox.border_width=5
						items_hbox.pack_start($settings_settingsbox,true,true)
						$settings_listvalues={}
						$settings_lists[selecteditem].each_pair { |key,value|
						
							if value.class==TrueClass || value.class==FalseClass then
							
								# True/False are handled with checkboxes
								
								$settings_listvalues[key]=Gtk::CheckButton.new(key.to_s,false)
								$settings_settingsbox.pack_start(settings_label($settings_listvalues[key]),false,true)
								$settings_listvalues[key].active=value
								
							else
						
								$settings_settingsbox.pack_start(settings_label(Gtk::Label.new(key.to_s)),false,true)
								$settings_listvalues[key]=Gtk::Entry.new
								$settings_listvalues[key].text=value
								$settings_settingsbox.pack_start($settings_listvalues[key],false,true)
								
							end
						}
						$settings_listselected=selecteditem
						$settings_settingsbox.show_all
					end
				}

				settings_updateplaylists

				editorvbox=Gtk::VBox.new(false,5)
				editorvbox.pack_start(boxit($settings_listsbox),true,true)
				editorvbox.pack_start(buttonbox=Gtk::HBox.new(false,5),false,true)
				buttonbox.pack_start(deletebutton=Gtk::Button.new("Delete",false),false,true)
				
				deletebutton.signal_connect("clicked") {
				
					# Saves the latest fields modifies
					settings_savelistdata
					
					iter =($settings_listsbox.selection.selected ? $settings_listsbox.selection.selected : nil )
					
					if (iter!=nil) then

						if (dialog=Gtk::MessageDialog.new($settings_window, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::WARNING, Gtk::MessageDialog::BUTTONS_YES_NO, "Do you really want to delete this playlist?")).run==Gtk::Dialog::RESPONSE_YES then
							dialog.destroy
							
							# dirty entry deletion ;)
							$settings_lists[iter[1]]=nil
							$settings_listslist.remove(iter)

							# reset the selected item
							$settings_listselected=-1

							# clear the editor panel						
							items_hbox.remove($settings_settingsbox) if $settings_settingsbox!=nil
							
						end
						
					end
				
				}

				buttonbox.pack_start(moveup=Gtk::Button.new("Up",false),false,true)
				
				moveup.signal_connect("clicked") {
				
					# Saves the latest fields modifies
					settings_savelistdata
					
					iter=($settings_listsbox.selection.selected ? $settings_listsbox.selection.selected : nil )
					
					if (iter!=nil) then
						pos=iter[1]-1
						while (pos>-1 && $settings_lists[pos]==nil) do pos=pos-1 end
						if pos>-1 then
							tmp=$settings_lists[pos]
							$settings_lists[pos]=$settings_lists[iter[1]]
							$settings_lists[iter[1]]=tmp
							$settings_lists.compact!
							# reset the selected item
							$settings_listselected=-1
							# clear the editor panel						
							items_hbox.remove($settings_settingsbox) if $settings_settingsbox!=nil							
							settings_updateplaylists
						end
					end
				
				}

				buttonbox.pack_start(moveup=Gtk::Button.new("Down",false),false,true)
				
				moveup.signal_connect("clicked") {
				
					# Saves the latest fields modifies
					settings_savelistdata
					
					iter=($settings_listsbox.selection.selected ? $settings_listsbox.selection.selected : nil )
					
					if (iter!=nil) then
						pos=iter[1]+1
						while (pos<$settings_lists.length && $settings_lists[pos]==nil) do pos=pos+1 end
						if pos<$settings_lists.length then
							tmp=$settings_lists[pos]
							$settings_lists[pos]=$settings_lists[iter[1]]
							$settings_lists[iter[1]]=tmp
							$settings_lists.compact!
							# reset the selected item
							$settings_listselected=-1
							# clear the editor panel						
							items_hbox.remove($settings_settingsbox) if $settings_settingsbox!=nil							
							settings_updateplaylists
						end
					end
				
				}

				
				buttonbox.pack_start(addnew=Gtk::ComboBox.new,false,true)
				addnew.append_text("Add new...")
				addnew.active=0
				
				$settings_templates.each { |item|
					addnew.append_text(item[:label])
				}
				
				addnew.signal_connect("changed") {
					optionindex=$settings_templates.index{|x|x[:label]==addnew.active_text}
					if (optionindex!=nil) then
						newitem={}
						$settings_templates[optionindex][:content].each_pair { |key,value| newitem[key]=value }
						$settings_lists << newitem
						new=$settings_listslist.append
						new[0]=$settings_lists[$settings_lists.length-1][:label]
						new[1]=$settings_lists.length-1
						addnew.active=0
					end
				}
				
				$settings_settingsbox=nil
				items_hbox.pack_start(editorvbox,true,true)


			elsif page[:items]==:columns then

					vbox=Gtk::VBox.new(false,5)
					vbox.border_width=5
					
					vbox.pack_start(settings_label(Gtk::Label.new("Double click an item on available columns to add it to the playlist view.\nDouble click a column ID on showed columns to remove it.")),false,true)

					nbook.append_page(vbox,Gtk::Label.new(page[:label]))
					
					mbox=Gtk::HBox.new(true)
					vbox.pack_start(mbox,true, true)
					
					$settings_columns = Gtk::TreeView.new($settings_columnslist = Gtk::ListStore.new(String))
					$settings_columns.append_column( Gtk::TreeViewColumn.new("Show",Gtk::CellRendererText.new,:text=>0) )
					$settings_columns.signal_connect("row-activated") { |view, path, column| 
						if iter = view.model.get_iter(path) then
							$settings_availcolumnslist.append[0]=iter[0]
							$settings_columnslist.remove(iter)
						end
					}
					
					loaded_columns.each { |key|
						$settings_columnslist.append[0]=key
						columns.delete(key)
					}
					
					mbox.pack_start(boxit($settings_columns),true,true)

					$settings_availcolumns = Gtk::TreeView.new($settings_availcolumnslist = Gtk::ListStore.new(String))
					$settings_availcolumns.append_column( Gtk::TreeViewColumn.new("Available",Gtk::CellRendererText.new,:text=>0) )

					columns.each { |key|
						$settings_availcolumnslist.append[0]=key
					}

					$settings_availcolumns.signal_connect("row-activated") { |view, path, column| 
						if iter = view.model.get_iter(path) then
							$settings_columnslist.append[0]=iter[0]
							$settings_availcolumnslist.remove(iter)
						end
					}

					mbox.pack_start(boxit($settings_availcolumns),true,true)
			
			else
				# Generical settings handler
				
				keys=[]
				if page[:items]!=:others then
					keys.concat(page[:items])
				else
					keys.concat(allitems)
				end

				if keys.length > 0 then
					
					mbox=Gtk::Table.new(1, 2, false)
					mbox.border_width=5
					mbox.column_spacings=5
					nbook.append_page(mbox,Gtk::Label.new(page[:label]));
					
					i=0
					keys.each { |keyname|
						value=$settings_config[:opt][keyname]
						if value!=nil then
						
							allitems.delete(keyname)

							mbox.n_rows=i+1
							label = ( $settings_details[keyname] ?  $settings_details[keyname][:label] :  keyname.to_s )

							if value.class==Fixnum then
							
								# Numbers are handled by spin buttons
								
								mbox.attach(settings_label(Gtk::Label.new(label)), 
										  0, 1, i, i+1,
										  Gtk::FILL, Gtk::FILL)

								$settings_values[keyname]=Gtk::SpinButton.new(0,99999999,1)
								
								$settings_values[keyname].value=value.to_i
								
								mbox.attach($settings_values[keyname], 
										  1, 2, i, i+1,
										  Gtk::FILL, Gtk::FILL)


							elsif value.class==TrueClass || value.class==FalseClass then
							
								# True/False are handled with checkboxes
								
								$settings_values[keyname]=Gtk::CheckButton.new(label,false)
								
								mbox.attach(settings_label($settings_values[keyname]), 
										  0, 2, i, i+1, 
										  Gtk::FILL, Gtk::FILL)
								$settings_values[keyname].active = ( value == true )
								
							elsif value.class==Array || value.class==String then
							
								# Lists and texts are handled with plain text editor
								# Arrays will be handled as a list separated with commas.
							
								mbox.attach(settings_label(Gtk::Label.new(label)), 
										  0, 1, i, i+1,
										  Gtk::FILL, Gtk::FILL)

								$settings_values[keyname]=Gtk::Entry.new
								
								if value.class==Array then
									value=value.join(",")
								end
								
								# Password fields have hidden chars
								if $settings_details[keyname][:password]!= nil then
									$settings_values[keyname].visibility=false
								end

				
								openbutton=nil
								if $settings_details[keyname][:directory]!= nil then
									openbutton=Gtk::Button.new("Choose")
									openbutton.signal_connect("clicked") {
									
										dialog = Gtk::FileChooserDialog.new("Select directory",
																			 $settings_window,
																			 Gtk::FileChooser::ACTION_SELECT_FOLDER,
																			 nil,
																			 [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
																			 [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])

										if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
										  $settings_values[keyname].text=dialog.filename
										end
										dialog.destroy								
	
									}
								end
								
								$settings_values[keyname].text=value.to_s
								
								if openbutton==nil then
									
									mbox.attach($settings_values[keyname], 
											  1, 2, i, i+1,
											  Gtk::FILL, Gtk::FILL)
								
								else

									mbox.attach(Gtk::HBox.new.pack_start($settings_values[keyname],true,true).pack_start(openbutton,false,true), 
											  1, 2, i, i+1,
											  Gtk::FILL, Gtk::FILL)
								
								end

							elsif

								mbox.attach(settings_label(Gtk::Label.new("#{label} type is not handled (#{value.class}).")), 
										  0, 2, i, i+1,
										  Gtk::FILL, Gtk::FILL)
							
							end
							

							# add notes
							if $settings_details[keyname]!=nil && $settings_details[keyname][:notes]!=nil then
								i=i+1
								mbox.n_rows=i+1
								mbox.attach(settings_label(Gtk::Label.new($settings_details[keyname][:notes])), 
										  1, 2, i, i+1,
										  Gtk::FILL, Gtk::FILL)
							end
							
						end
						i=i+1						
					 }
					end
				end
		}
		$settings_window.show_all
	  end
 end
