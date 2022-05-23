extends Control

signal data_changed
var path:String

func on_files_dropped(files:PoolStringArray,_s=null):
	for fp in files:
		if fp.get_extension() == "mp3" or fp.get_extension() == "ogg" or fp.get_extension() == "wav":
			path = fp
			$Label.text = path.get_file()
			emit_signal("data_changed")
			return

func use_clipboard():
	var clip = OS.clipboard
	if clip.is_abs_path() and (clip.get_extension() == "mp3" or clip.get_extension() == "ogg" or clip.get_extension() == "wav"):
		path = clip
		$Label.text = path.get_file()
		emit_signal("data_changed")
		return

var time_to_next_clip_check = 1.5
func _process(delta):
	time_to_next_clip_check -= delta
	if time_to_next_clip_check <= 0 and get_parent().is_visible_in_tree():
		time_to_next_clip_check += 1.5
		var clip = OS.clipboard
		var v:bool = clip.is_abs_path() and (clip.get_extension() == "mp3" or clip.get_extension() == "ogg" or clip.get_extension() == "wav")
		$File.visible = !v
		$File2.visible = v
		$Clipboard.visible = v

func _ready():
	get_tree().connect("files_dropped",self,"on_files_dropped")
	$Clipboard.connect("pressed",self,"use_clipboard")

