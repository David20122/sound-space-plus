extends Label

func _ready():
	text = "Rhythia [%s]" % ProjectSettings.get_setting("application/config/version")
