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

func update_folders():
	Folders.executable = OS.get_executable_path()
	for key in _folders.keys():
		var value = _folders[key]
		match value[0]:
			RootFolder.USER: Folders[key] = Folders.user.plus_file(value[1])
			RootFolder.RES: Folders[key] = Folders.res.plus_file(value[1])
			RootFolder.EXECUTABLE: Folders[key] = Folders.executable.plus_file(value[1])

enum AudioFormat {
	UNKNOWN
	MP3
	OGG
	WAV
}

const StatusMessages = {
	DEBUG = [Color("#2483b3"),"This is a development build. Some features may not function correctly."]
}

func _ready():
	update_folders()