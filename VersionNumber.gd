extends Label

var ARCW_MODE = false

func _ready():
	if Input.is_action_pressed("arcw1") and Input.is_action_pressed("arcw2") and Input.is_action_pressed("arcw3") and Input.is_action_pressed("arcw4"):
		ARCW_MODE = true
	if not ARCW_MODE:
		text = "Sound Space+   v%s" % ProjectSettings.get_setting("application/config/version")
	else:
		text = "Arcw Sex :hardcoresex:"
