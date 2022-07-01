extends Camera

var phase:int = 0

func _ready():
	fov = ProjectSettings.get_setting("application/config/fov")
