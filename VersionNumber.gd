extends Label

func _ready():
	text = "Sound Space+   v%s" % ProjectSettings.get_setting("application/config/version")
