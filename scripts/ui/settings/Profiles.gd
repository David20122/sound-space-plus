extends MenuButton

var profiles
var file:File

func save_profile(path:String):
	if path:
		var saveLoc:File = File.new()
		var err:int = saveLoc.open(path,File.WRITE)
		if err != OK: print("file.open errored - code " + String(err))
		saveLoc.store_string(file.to_string())
		saveLoc.close()

func on_pressed(i):
	if i == profiles.size():
		print("creating profile")
		file= File.new()
		var err:int = file.open(Globals.p("user://settings.json"), File.READ)
		if err == OK: # will be FILE_NOT_FOUND if it doesn't exist
			Globals.file_sel.save_file(
				self,
				"save_profile",
				["*.settings.json ; Settings Profile (*.settings.json)"],
				Globals.p("user://") + "profile.settings.json"
			)
		return
	var profile = profiles[i]
	print("Loading profile: " + profile)
	# overwrite Globals.p("user://settings.json") with the selected profile
	# Rhythia.is_switch_profile = true
	get_viewport().get_node("Menu").black_fade_target = true
	yield(get_tree().create_timer(0.35),"timeout")
	get_tree().change_scene("res://scenes/init.tscn")
	Rhythia.load_saved_settings(profile)
	Rhythia.save_settings()
	file.close()
	

func _ready():
	# for every file Globals.p("user://<something>.settings.json") add an item with the name of the file
	profiles = Globals.get_files_recursive([Globals.p("user://")], 1, "json").files # just putting .settings.json here doesn't work :(
	# remove ones that are not settings profiles
	print(profiles)
	for i in range(profiles.size() - 1, -1, -1): # reverse traversal, prevent bad index
		if profiles[i].find(".settings.json") == -1:
			profiles.remove(i)

	#.substr(profiles[i].find_last("/") + 1, profiles[i].find(".settings.json") - profiles[i].find_last("/") - 1)
	for i in range(profiles.size()):
		get_popup().add_item(profiles[i].substr(profiles[i].find_last("/") + 1, profiles[i].find(".settings.json") - profiles[i].find_last("/") - 1), i)
	get_popup().add_item("Create/Overwrite From Current", -1)
	get_popup().connect("id_pressed",self,"on_pressed")
	
