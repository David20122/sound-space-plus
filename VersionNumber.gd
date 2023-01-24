extends Label

func _ready():
	text = "Sound Space Plus [%s]" % ProjectSettings.get_setting("application/config/version")
