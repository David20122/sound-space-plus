extends Node

onready var rootg = get_tree().root

enum {
	CAMERA_HALF_LOCK
	CAMERA_FULL_LOCK
}

enum {
	RS_CURSOR = 0
	RS_HIT = 1
	RS_MISS = 2
	RS_PAUSE = 3
	RS_GIVEUP = 4
	RS_END = 5
	RS_START_UNPAUSE = 6
	RS_CANCEL_UNPAUSE = 7
	RS_FINISH_UNPAUSE = 8
	RS_SKIP = 9
	RS_GIVEUP_CANCEL = 10
}

enum {
	MAPR_FILE = 0
	MAPR_FILE_ABSOLUTE = 1
	MAPR_FILE_SONG_ABSOLUTE = 2
	MAPR_EMBEDDED = 3
	MAPR_EMBEDDED_SONG_ABSOLUTE = 4
}

enum {
	REGISTRY_MAP
	REGISTRY_COLORSET
}

enum {
	FRIEND_LOWER_RIGHT
	FRIEND_LOWER_LEFT
	FRIEND_UPPER_RIGHT
	FRIEND_UPPER_LEFT
	FRIEND_FILL_GRID
	FRIEND_BEHIND_GRID
	FRIEND_BELOW_UI_L
	FRIEND_BELOW_UI_R
}

enum {
	CURSOR_CUSTOM_COLOR = 0
	CURSOR_RAINBOW = 1
	CURSOR_NOTE_COLOR = 2
}

enum {
	SPEED_NORMAL = 0
	SPEED_MMM = 1
	SPEED_MM = 2
	SPEED_M = 3
	SPEED_P = 4
	SPEED_PP = 5
	SPEED_PPP = 6
	SPEED_CUSTOM = 7
	SPEED_PPPP = 8
}

onready var speed_multi:Array = [
	1, # normal
	1/1.35, # ---
	1/1.25, # --
	1/1.15, # -
	1.15, # +
	1.25, # ++
	1.35, # +++
	SSP.custom_speed,
	1.45, # ++++
]

enum {
	END_PASS
	END_FAIL
	END_GIVEUP
}

enum {
	NSTATE_ACTIVE
	NSTATE_HIT
	NSTATE_MISS
}

enum {
	SEARCH_ALLTEXT
	SEARCH_ID
	SEARCH_NAME
	SEARCH_CREATOR
	SEARCH_RARITY
	SEARCH_DIFFICULTY
	SEARCH_TYPE
}

enum {
	DIFF_UNKNOWN = -1
	DIFF_EASY = 0
	DIFF_MEDIUM = 1
	DIFF_HARD = 2
	DIFF_LOGIC = 3
	DIFF_AMOGUS = 4
}

enum {
	MAP_TXT = 0
	MAP_RAW = 1
	MAP_VULNUS = 2
	MAP_SSPM = 3
	MAP_NET = 4
	MAP_SSPM2 = 5
}

enum {
	HP_SOUNDSPACE = 0
	HP_OLD = 1
}

enum {
	GRADE_SSP = 0
	GRADE_LEGACY = 1
}

enum {
	VR_GENERIC
	VR_OCULUS
	VR_VIVE
}

enum {
	NOTIFY_INFO = 0
	NOTIFY_WARN = 1
	NOTIFY_ERROR = 2
	NOTIFY_SUCCEED = 3
}

const difficulty_names:Dictionary = {
	-1: "N/A",
	0: "EASY",
	1: "MEDIUM",
	2: "HARD",
	3: "LOGIC?",
	4: "助",
#	4: "包",
}

const difficulty_colors:Dictionary = {
	-1: Color("#ffffff"),
	0: Color("#00ff00"),
	1: Color("#ffb900"),
	2: Color("#ff0000"),
	3: Color("#d76aff"),
	4: Color("#36304f"),
#	4: Color("#00f3ff"),
}

var errornum:int = 0
func p(path:String) -> String:
	var base_path = "user://"
	var dir:Directory = Directory.new()
	if OS.has_feature("Android"):
		base_path = OS.get_user_data_dir() + "/"
	return path.replace("user://",base_path)

var error_sound:AudioStream

#var audioLoader:AudioLoader = AudioLoader.new()
#var imageLoader:ImageLoader = ImageLoader.new()
var confirm_prompt:ConfirmationPrompt2D
var file_sel:FileSelector2D
var notify_gui:Notify2D

func comma_sep(number):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	return res

signal recurse_result
func get_files_recursive(
	paths:Array,
	max_layers:int=5,
	filter_ext:String="",
	folders_with:String="",
	pause_amt:int=(-1) # Outputs through the signal recurse_result if used
):
	var a = OS.get_ticks_usec()
	if pause_amt != -1: yield(get_tree(),"idle_frame")
	print("-- start recurse --")
	print(paths)
	var dir:Directory = Directory.new()
	
	var files:Array = []
	var folders:Array = []
	
	var subfolders:Array = []
	var subfolders2:Array = paths
	
	var i = 0
	var layer = 0
	while subfolders2.size() != 0:
		layer += 1
		
		if layer > max_layers:
			print("recursed too deep! stopping!")
			break
		
		i += 1
		if pause_amt != -1 and (pause_amt == 0 or ((i%pause_amt) == 0)):
			yield(get_tree(),"idle_frame")
		
#		print("start layer %s" % layer)
		subfolders = subfolders2
		subfolders2 = []
		
		while subfolders.size() != 0:
			i += 1
			if pause_amt != -1 and (pause_amt == 0 or ((i%pause_amt) == 0)):
				yield(get_tree(),"idle_frame")
			
			var cpath:String = ProjectSettings.globalize_path(subfolders.pop_back().strip_edges())
			cpath = cpath.simplify_path()
			var err = dir.open(cpath)
			if err == OK:
				err = dir.list_dir_begin(true)
				if err == OK:
					var n:String = dir.get_next()
					var p:String = cpath.plus_file(n)
					while n:
						i += 1
						if pause_amt != -1 and (pause_amt == 0 or ((i%pause_amt) == 0)):
							yield(get_tree(),"idle_frame")
						
						if folders_with != "" and n == folders_with:
							folders.append(cpath)
						
						if dir.dir_exists(p):
							if folders_with == "": folders.append(p)
							subfolders2.append(p)
						elif filter_ext == "" or p.get_extension() == filter_ext:
							files.append(p)
						
						n = dir.get_next()
						p = cpath.plus_file(n)
					dir.list_dir_end()
				else:
					print("failed to list files in folder %s (error code %s)" % [cpath,err])
			else:
				print("failed to change to folder %s (error code %s)" % [cpath,err])
			
	
	print("-- end recurse - took %s usec --" % [Globals.comma_sep(OS.get_ticks_usec() - a)])
	if pause_amt != -1:
		emit_signal("recurse_result",{files = files, folders = folders})
	return {files = files, folders = folders}

func notify(type:int,body:String,title:String="Notification",time:float=5):
	notify_gui.notify(type,body,title,time)

var url_regex:RegEx = RegEx.new()
func is_valid_url(text:String):
	if text == "valid": return false
	return (url_regex.sub(text,"valid") == "valid")

var fps_visible:bool = false
var fps_disp:Label = Label.new()

var console_open:bool = false
var con:LineEdit

signal console_sent
func _process(delta):
	notify_gui.raise()
	
	if Input.is_action_just_pressed("debug_notify"):
		notify(NOTIFY_INFO,"This is a notification!","Debug Notify")
	if Input.is_action_just_pressed("console"):
		if !console_open:
			console_open = true
			con = LineEdit.new()
			con.expand_to_text_length = true
			con.theme = load("res://uitheme.tres")
			con.set("custom_fonts/font",load("res://assets/font/console.tres"))
			get_parent().add_child(con)
			con.rect_position = Vector2(5,5)
			con.rect_size.x = 400
			con.raise()
			con.grab_focus()
			
			yield(con,"text_entered")
			var ctxt = con.text
			console_open = false
			con.queue_free()
			if ctxt.strip_edges() != "":
				var all = ctxt.split(";",true)
				for txt in all:
					txt = txt.strip_edges()
					var cmd = txt.split(" ",true,1)[0]
					emit_signal("console_sent",cmd,txt.trim_prefix(cmd).strip_edges())
	if console_open:
		con.raise()
	elif fps_visible:
		fps_disp.text = "%s fps" % Engine.get_frames_per_second()
		fps_disp.raise()
	
	if Input.is_action_just_pressed("fps"):
		if !fps_disp.is_inside_tree():
			rootg.add_child(fps_disp)
		fps_visible = !fps_visible
		fps_disp.visible = fps_visible

var cmdline:Dictionary = {}
func _ready():
	var thread = Thread.new()
	SSP.is_init = true
	thread.start(SSP,"do_init")
	
	var disable_intro = false
	var file:File = File.new()
	if file.file_exists(Globals.p("user://settings.json")):
		var err = file.open(Globals.p("user://settings.json"),File.READ)
		if err != OK:
			print("file.open failed"); return -2
		var decode = JSON.parse(file.get_as_text())
		file.close()
		if !decode.error:
			disable_intro = decode.result.has("disable_intro") and decode.result.disable_intro
	if !disable_intro: get_tree().call_deferred("change_scene","res://scenes/Intro.tscn")
	
	url_regex.compile(
		"((https?)://)[\\w\\-.]{2,256}(:\\d{1,5})?(/[\\w@:%._\\-+~&=]+)+/?"
	)
	
	confirm_prompt = load("res://prefabs/menu/confirm.tscn").instance()
	rootg.call_deferred("add_child",confirm_prompt)
	
	file_sel = load("res://prefabs/menu/filesel.tscn").instance()
	rootg.call_deferred("add_child",file_sel)
	
	notify_gui = load("res://prefabs/menu/notification_gui.tscn").instance()
	rootg.call_deferred("add_child",notify_gui)
	
	fps_disp.margin_left = 15
	fps_disp.margin_top = 15
	fps_disp.margin_right = 0
	fps_disp.margin_bottom = 0
	fps_disp.set("custom_fonts/font",load("res://assets/font/debug2.tres"))
	
	for arg in OS.get_cmdline_args():
		if arg.find("=") > -1:
			var key_value = arg.split("=")
			cmdline[key_value[0].lstrip("--")] = key_value[1]
		else:
			cmdline[arg.lstrip("--")] = ""
	
	if OS.has_feature("debug"):
		rootg.call_deferred("add_child",fps_disp)
		fps_visible = true
