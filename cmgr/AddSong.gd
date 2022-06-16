extends Panel

const NativeDialogs := preload("res://addons/native_dialogs/native_dialogs.gd")
var gdunzip = load("res://classes/gdunzip.gd").new()

var dir:Directory = Directory.new()
var file:File = File.new()
var openFile:NativeDialogs.OpenFile
var openFolder:NativeDialogs.SelectFolder

export(Texture) var cover_placeholder

var song:Song

var maptype:int = -1
var filetype:int = -1
var opening:int = -1
var step:int = 0
var path:String = ""
var musicPath:String = ""
var dataPath:String = ""

enum {
	T_TXT
	T_SSPM
	T_VULNUS
	T_SSPMR
}
enum {
	F_DIR
	F_ZIP
}
enum {
	FO_VZIP
	FO_VDIR
	FO_COVER
	FO_SSPM
}

func select_type(type:int):
	if type == T_VULNUS:
		maptype = T_VULNUS
		step = 1
		$SelectType.visible = false
		$VulnusFile.visible = true
	elif type == T_SSPM:
		print("opening sspm")
		opening = FO_SSPM
		openFile.clear_filters()
		openFile.add_filter("*.sspm ; Sound Space+ map")
		openFile.initial_path = "~/Downloads"
		openFile.title = "Select SS+ map..."
		openFile.multiselect = false
		openFile.show()

func sel_filetype(type:int):
	print(type)
	if maptype == T_VULNUS:
		print("opening a vulnus map")
		if type == F_ZIP:
			print("opening vulnus zip")
			opening = FO_VZIP
			openFile.clear_filters()
			openFile.add_filter("*.zip, *.rar, *.7z, *.gz ; archive files")
			openFile.initial_path = "~/Downloads"
			openFile.title = "Select Vulnus map..."
			openFile.multiselect = false
			openFile.show()
		elif type == F_DIR:
			print("opening vulnus folder")
			opening = FO_VDIR
			openFolder.initial_path = "~/Downloads"
			openFolder.title = "Select Vulnus map..."
			openFolder.show()
		

const valid_chars = "0123456789abcdefghijklmnopqrstuvwxyz_-"

func generate_id(sname:String,mapper:String):
	var txt:String = ""
	if mapper.length() != 0:
		for i in range(mapper.length()):
			if mapper.to_lower()[i].is_subsequence_of(valid_chars):
				txt += mapper.to_lower()[i]
			elif mapper[i] == " " and txt[txt.length()-1] != "_":
				txt += "_"
		if txt[txt.length()-1] != "_": txt += "_"
	for i in range(sname.length()):
		if sname.to_lower()[i].is_subsequence_of(valid_chars):
			txt += sname.to_lower()[i]
		elif sname[i] == " " and txt[txt.length()-1] != "_": txt += "_"
	return txt.trim_prefix("_").trim_suffix("_")


var edit_pop:bool = false
func populate_edit_screen():
	edit_pop = true
	$Edit/Info/Id.text = song.id
	$Edit/Info/Id/T.text = song.id
	$Edit/Info/SongName.text = song.name
	$Edit/Info/SongName/T.text = song.name
	$Edit/Info/Difficulty.text = "Difficulty: " + Globals.difficulty_names[song.difficulty]
	$Edit/Info/Mapper.text = "Mapper: %s" % song.creator
	$Edit/Info/Mapper/T.text = song.creator
	$Edit/Info/Difficulty/B.selected = (song.difficulty + 1)
	if song.has_cover:
		$Edit/Cover/T.texture = song.cover
		$Edit/Cover/C.disabled = false
		$Edit/Cover/C.pressed = true
	else:
		$Edit/Cover/C.disabled = true
		$Edit/Cover/C.pressed = false
	if SSP.registry_song.idx_id.has(song.id):
		$Edit/done.disabled = true
		$Edit/done/Title.text = "ID in use"
	else:
		$Edit/done.disabled = false
		$Edit/done/Title.text = "Finish"
	edit_pop = false

func import_vulnus_folder():
	print("Locating meta.json...")
	yield(get_tree(),"idle_frame")
	
	dir.open(path)
	if !dir.file_exists("meta.json"):
		print("Possible nested folder - searching for meta.json")
		yield(get_tree(),"idle_frame")
		var n = dir.get_next()
		while n:
			if dir.file_exists(n.plus_file("meta.json")):
				print("Found meta.json in '%s'" % n)
				yield(get_tree(),"idle_frame")
				path = path.plus_file(n)
				break
		if path == "user://temp": # Meta.json wasn't found anywhere
			print("couldn't find meta.json")
			$VulnusFile/Error.text = "Missing meta.json (check if the zip file contains a folder, and, if it does, extract it)"
			$VulnusFile/Error.visible = true
			return
	
	print("Located! Loading meta.json...")
	yield(get_tree(),"idle_frame")
	var res = file.open(path.plus_file("meta.json"),File.READ)
	if res != OK:
		print("meta.json: file open error %s" % res)
		$VulnusFile/Error.text = "meta.json: error opening file (file error %s) % res"
		$VulnusFile/Error.visible = true
		return
	
	var metatxt:String = file.get_as_text()
	file.close()
	print("Loaded! Reading metadata now...")
	yield(get_tree(),"idle_frame")
	var meta:Dictionary = parse_json(metatxt)
	print("Parsed!")
	yield(get_tree(),"idle_frame")
	var artist:String = meta.get("_artist","Unknown Artist")
	var difficulties:Array = meta.get("_difficulties",[])
	var mappers:Array = meta.get("_mappers",[])
	var music_path:String = meta.get("_music","**missing**")
	var title:String = meta.get("_title","Unknown Song")
	
	print("Data loaded! Making sure we have everything we need...")
	yield(get_tree(),"idle_frame")
	
	if difficulties.size() == 0:
		print("no difficulties")
		$VulnusFile/Error.text = "No difficulties defined - cannot get map data"
		$VulnusFile/Error.visible = true
		return
	if music_path == "**missing**" or !music_path.is_valid_filename():
		print("invalid music path")
		$VulnusFile/Error.text = "Path to music is missing or invalid"
		$VulnusFile/Error.visible = true
		return
	
	if !file.file_exists(path.plus_file(music_path)):
		print("music file doesn't exist")
		$VulnusFile/Error.text = "Music file does not exist (%s)" % [music_path]
		$VulnusFile/Error.visible = true
		return
	if !file.file_exists(path.plus_file(difficulties[0])):
		print("map data file doesn't exist")
		$VulnusFile/Error.text = "Map data file does not exist (%s)" % [difficulties[0]]
		$VulnusFile/Error.visible = true
		return
	
	print("Everything seems to be present!")
	print("Building metadata...")
	yield(get_tree(),"idle_frame")
	
	var conc:String = ""
	for i in range(mappers.size()):
		if i != 0: conc += ", "
		conc += mappers[i]
	
	var songname = "%s - %s" % [artist,title]
	var id = generate_id(songname,conc)
	print("Everything is ready! Loading map...")
	yield(get_tree(),"idle_frame")
	
	song = Song.new(id,songname,conc)
	song.setup_from_vulnus_json("%s/%s" % [path,difficulties[0]], "%s/%s" % [path,music_path])
	
	var cover = Globals.imageLoader.load_if_exists(path.plus_file("cover"))
	if cover:
		song.cover = cover
		song.has_cover = true
	
	print("IMPORTED SUCCESS!!! PARTY TIME!")
	$VulnusFile/Success.text = "map imported as %s!" % [id]
	$VulnusFile/Success.visible = true
	yield(get_tree(),"idle_frame")
	
	$VulnusFile.visible = false
	populate_edit_screen()
	$Edit.visible = true

func file_selected(files:PoolStringArray):
	if files.size() == 0: return
	match opening:
		FO_COVER:
			if !song: return
			var cover = Globals.imageLoader.load_file(files[0])
			if cover:
				song.cover = cover
				song.has_cover = true
				$Edit/Cover/T.texture = cover
				$Edit/Cover/C.disabled = false
				$Edit/Cover/C.pressed = true
		FO_SSPM:
			song = Song.new()
			song.load_from_sspm(files[0])
			$SelectType.visible = false
			populate_edit_screen()
			$Edit.visible = true
		FO_VZIP:
			$VulnusFile/Success.visible = false
			$VulnusFile/Error.visible = false
			
			print("Making temp dir")
			yield(get_tree(),"idle_frame")
			dir.open("user://")
			if dir.dir_exists("user://temp"):
				print("Removing old temp dir")
				yield(get_tree(),"idle_frame")
				dir.remove("user://temp")
			dir.make_dir("user://temp")
			
			print("Extracting zip file...")
			yield(get_tree(),"idle_frame")
			
			var output = []
			if OS.has_feature("Windows"):
				var binarypath = OS.get_executable_path().get_base_dir().plus_file("7z.exe")
				var args = [
					# x -bb0 -y -bd ./Dimrain47_-_at_the_speed_of_light.zip *
					'x',
					'-bb0',
					'-y',
					'-bd',
					'-o"%s"' % [ProjectSettings.globalize_path("user://temp").replace("\\","/")],
					'"%s"' % [files[0].replace("\\","/")],
					'*'
				]
				var exit_code = OS.execute(binarypath, args, true, output)
				
				if exit_code != 0:
					print("nonzero exit code of %s" % [exit_code])
					$VulnusFile/Error.text = "error occurred while extracting zip (exit code %s)" % [exit_code]
					$VulnusFile/Error.visible = true
					return
			elif OS.has_feature("X11"):
				var binarypath = OS.get_executable_path().get_base_dir().plus_file("7zz")
				var args = [
					# x -bb0 -y -bd ./Dimrain47_-_at_the_speed_of_light.zip *
					'x',
					'-bb0',
					'-y',
					'-bd',
					'-o"%s"' % [ProjectSettings.globalize_path("user://temp").replace('"','\\"')],
					'"%s"' % [files[0].replace('"','\\"')],
					'*'
				]
				var exit_code = OS.execute(binarypath, args, true, output)
				
				if exit_code != 0:
					print("nonzero exit code of %s" % [exit_code])
					$VulnusFile/Error.text = "error occurred while extracting zip (exit code %s)" % [exit_code]
					$VulnusFile/Error.visible = true
					return
			else:
				print("platform doesn't have a 7zip binary")
				$VulnusFile/Error.text = "zip imports currently aren't supported on this platform"
				$VulnusFile/Error.visible = true
				return
			
			path = "user://temp"
			import_vulnus_folder()
		FO_VDIR:
			$VulnusFile/Success.visible = false
			$VulnusFile/Error.visible = false
			path = files[0]
			import_vulnus_folder()
			

func folder_selected(path:String):
	if path != "": file_selected(PoolStringArray([path]))

func edit_field(field:String,done:bool=false):
	if done:
		if !Input.is_action_just_pressed("ui_select"):
			match field:
				"name":
					if $Edit/Info/SongName/T.text.length() != 0:
						song.name = $Edit/Info/SongName/T.text
						$Edit/Info/SongName/T.visible = false
						$Edit/Info/SongName.text = song.name
				"mapper":
					if $Edit/Info/Mapper/T.text.length() != 0:
						song.creator = $Edit/Info/Mapper/T.text
						$Edit/Info/Mapper/T.visible = false
						$Edit/Info/Mapper.text = "Mapper: %s" % song.creator
				"id":
					var id = $Edit/Info/Id/T.text
					if id.length() == 0 or id.begins_with("_") or !("n" + id).replace("-","").is_valid_identifier():
						return
					else:
						song.id = id
						$Edit/Info/Id/T.visible = false
						$Edit/Info/Id.text = song.id
						if SSP.registry_song.idx_id.has(song.id):
							$Edit/done.disabled = true
							$Edit/done/Title.text = "ID in use"
						else:
							$Edit/done.disabled = false
							$Edit/done/Title.text = "Finish"
	else:
		match field:
			"name":
				$Edit/Info/SongName/T.visible = true
				$Edit/Info/SongName/T.grab_focus()
				$Edit/Info/SongName/T.select_all()
			"mapper":
				$Edit/Info/Mapper/T.visible = true
				$Edit/Info/Mapper/T.grab_focus()
				$Edit/Info/Mapper/T.select_all()
			"id":
				$Edit/Info/Id/T.visible = true
				$Edit/Info/Id/T.grab_focus()
				$Edit/Info/Id/T.select_all()

func onopen():
	maptype = -1
	filetype = -1
	step = 0
	path = ""
	musicPath = ""
	dataPath = ""
	for n in get_children():
		if n is Control:
			n.visible = (n == $Title or n == $SelectType)
	
	$VulnusFile/Success.visible = false
	$VulnusFile/Error.visible = false
	
	visible = true

func difficulty_sel(i:int):
	if edit_pop or !song: return
	song.difficulty = i - 1
	$Edit/Info/Difficulty.text = "Difficulty: " + Globals.difficulty_names[song.difficulty]

func set_use_cover(v:bool):
	song.has_cover = v

func do_coversel():
	openFile.hide()
	opening = FO_COVER
	openFile.clear_filters()
	openFile.add_filter("*.png, *.jpg, *.jpeg, *.webp, *.bmp ; Image files")
	openFile.initial_path = "~/Downloads"
	openFile.title = "Select cover image"
	openFile.multiselect = false
	openFile.show()

func finish_map():
	$Edit.visible = false
	$Finish.visible = true
	$Finish/ok.visible = false
	$Finish/Error.visible = false
	$Finish/Success.visible = false
	$Finish/Wait.visible = true
	yield(get_tree(),"idle_frame") # Make sure the screen updates
	
	var result = song.convert_to_sspm()
	
	$Finish/Wait.visible = false
	if result == "Converted!":
		SSP.registry_song.add_sspm_map("user://maps/%s.sspm" % song.id)
		$Finish/Success.visible = true
	else:
		$Finish/Error.text = result
		$Finish/Error.visible = true
	$Finish/ok.visible = true

func _ready():
	openFile = NativeDialogs.OpenFile.new()
	openFolder = NativeDialogs.SelectFolder.new()
	openFile.name = "FileDialog"
	openFile.name = "FolderDialog"
	
	$SelectType/txt.connect("pressed",self,"select_type",[T_TXT])
	$SelectType/sspm.connect("pressed",self,"select_type",[T_SSPM])
	$SelectType/vulnus.connect("pressed",self,"select_type",[T_VULNUS])
	$SelectType/sspmr.connect("pressed",self,"select_type",[T_SSPMR])
	
	$VulnusFile/zip.connect("pressed",self,"sel_filetype",[F_ZIP])
	$VulnusFile/folder.connect("pressed",self,"sel_filetype",[F_DIR])
	
	$Edit/Cover/T/B.connect("pressed",self,"do_coversel")
	$Edit/Cover/C.connect("toggled",self,"set_use_cover")
	$Edit/Info/Difficulty/B.add_item("N/A",0)
	$Edit/Info/Difficulty/B.add_item("Easy",1)
	$Edit/Info/Difficulty/B.add_item("Medium",2)
	$Edit/Info/Difficulty/B.add_item("Hard",3)
	$Edit/Info/Difficulty/B.add_item("Logic?",4)
	$Edit/Info/Difficulty/B.add_item("助",5)
	$Edit/Info/Difficulty/B.connect("item_selected",self,"difficulty_sel")
	$Edit/Info/SongName/B.connect("pressed",self,"edit_field",["name"])
	$Edit/Info/SongName/T.connect("focus_exited",self,"edit_field",["name",true])
	$Edit/Info/Mapper/B.connect("pressed",self,"edit_field",["mapper"])
	$Edit/Info/Mapper/T.connect("focus_exited",self,"edit_field",["mapper",true])
	$Edit/Info/Id/B.connect("pressed",self,"edit_field",["id"])
	$Edit/Info/Id/T.connect("focus_exited",self,"edit_field",["id",true])
	
	$Edit/done.connect("pressed",self,"finish_map")
	
	$Edit/cancel.connect("pressed",self,"onopen")
	$VulnusFile/cancel.connect("pressed",self,"onopen")
	$Finish/ok.connect("pressed",self,"onopen")
	
	openFile.connect("files_selected",self,"file_selected")
	openFolder.connect("folder_selected",self,"folder_selected")
	
	call_deferred("add_child",openFile)
	call_deferred("add_child",openFolder)
	call_deferred("onopen")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if $Edit/Info/SongName/T.visible: edit_field("name",true)
		if $Edit/Info/Mapper/T.visible: edit_field("mapper",true)
