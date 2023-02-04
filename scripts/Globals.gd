extends Node

enum RootFolder {
	USER
	RES
	EXECUTABLE
}

const Folders = {
	user = "user://",
	res = "res://",
	executable = ""
}
const _folders = {
	maps = [RootFolder.USER,"maps"]
}

func _ready():
	update_folders()

func update_folders():
	Folders.executable = OS.get_executable_path()
	for key in _folders.keys():
		var value = _folders[key]
		match value[0]:
			RootFolder.USER: Folders[key] = Folders.user.plus_file(value[1])
			RootFolder.RES: Folders[key] = Folders.res.plus_file(value[1])
			RootFolder.EXECUTABLE: Folders[key] = Folders.executable.plus_file(value[1])
