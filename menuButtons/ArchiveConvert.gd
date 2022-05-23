extends Button

var dir:Directory = Directory.new()

var confirm:bool = false

func _pressed():
	
	if dir.dir_exists("user://maps/ss_archive"): 
		OS.shell_open(ProjectSettings.globalize_path("user://packs"))
	elif confirm:
		SSP.do_archive_convert = true
		get_tree().change_scene("res://init.tscn")
	else:
		confirm = true
		text = "8 GB space required. Continue?"
		disabled = true
		yield(get_tree().create_timer(0.5),"timeout")
		disabled = false

func _ready():
	dir.open("user://packs")
	if !dir.dir_exists("user://packs/ssarchive"): visible = false
	if dir.file_exists("user://maps/ss_archive_3r2_-_star_rider.sspm"): 
		text = "Delete old ssarchive folder (8 GB)"
