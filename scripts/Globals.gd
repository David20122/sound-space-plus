extends Node

enum RootFolder {
	USER,
	RES,
	EXECUTABLE,
	SKIN
}

var Folders = {
	user = "user://",
	res = "res://",
	executable = "",
	skin = "",
}
const _folders = {
	skin = [RootFolder.RES,"assets"],
	maps = [RootFolder.USER,"maps"],
	playlists = [RootFolder.USER,"playlists"]
}

func update_folders():
	Folders.executable = OS.get_executable_path()
	for key in _folders.keys():
		var value = _folders[key]
		match value[0]:
			RootFolder.USER: Folders[key] = Folders.user.path_join(value[1])
			RootFolder.RES: Folders[key] = Folders.res.path_join(value[1])
			RootFolder.EXECUTABLE: Folders[key] = Folders.executable.path_join(value[1])
			RootFolder.SKIN: Folders[key] = Folders.skin.path_join(value[1])

enum AudioFormat {
	UNKNOWN,
	MP3,
	OGG,
	WAV
}

const StatusMessages = {
	DEBUG = [Color("#2483b3"),"This is a development build. Some features may not function correctly."],
	EDITOR = [Color("#2483b3"),"You are running the game from the editor. Some features may be disabled."]
}

func _ready():
	update_folders()
