extends Label

func _ready():
	text = "Sound Space Plus   v%s" % ProjectSettings.get_setting("application/config/version")
