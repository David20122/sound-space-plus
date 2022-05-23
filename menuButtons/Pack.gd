extends HBoxContainer

var path:String

func open_dir(): OS.shell_open(ProjectSettings.globalize_path(path))
func edit_maps():
	print("editing maps now")
	OS.shell_open(ProjectSettings.globalize_path(path + "/pack.sspmr"))

func setup(pakName:String,pakPath:String):
	var file:File = File.new()
	$EditMaps.visible = file.file_exists(pakPath + "/pack.sspmr")
	path = pakPath
	$Name.text = pakName
	$View.connect("pressed",self,"open_dir")
	$EditMaps.connect("pressed",self,"edit_maps")
