extends Label

func _ready():
	if Rhythia.boba_mode:
		text = "Rhythia [%s]" % ProjectSettings.get_setting("application/config/bobaversion")
	else:	
		text = "Rhythia [%s]" % ProjectSettings.get_setting("application/config/version")
