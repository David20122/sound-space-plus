extends Control

signal data_changed
var last_path:String

var use_file:bool = false
var data:String
var path:String


func on_files_dropped(files:PoolStringArray,_s=null):
	for fp in files:
		if fp.get_extension() == "txt":
			path = fp
			$Label.text = path.get_file()
			use_file = true
			emit_signal("data_changed")
			return

func use_clipboard():
	var clip = OS.clipboard
	if clip.split(",").size() >= 2 and clip.split(",")[1].split("|").size() == 3:
		use_file = false
		data = clip
		if data.length() > 25: $Label.text = data.substr(0,25) + "..."
		else: $Label.text = data
		emit_signal("data_changed")
	elif clip.is_abs_path() and clip.get_extension() == "txt":
		path = clip
		$Label.text = path.get_file()
		use_file = true
		emit_signal("data_changed")
		return
	else:
		$Clipboard.text = "not map data"
		yield(get_tree().create_timer(0.75),"timeout")
		$Clipboard.text = "from clipboard"

func _ready():
	get_tree().connect("files_dropped",self,"on_files_dropped")
	$Clipboard.connect("pressed",self,"use_clipboard")
#	if last_path: file_dialog.current_dir = last_path.get_base_dir()
#	elif OS.has_feature("Windows"): file_dialog.current_dir = ProjectSettings.globalize_path("user://../../..")
#	elif OS.has_environment("HOMEPATH"): file_dialog.current_dir = OS.get_environment("HOMEPATH")
#
#	add_child(file_dialog)
#	file_dialog.theme = Theme.new()
	
#	$File.connect("pressed",self,"open_file")

