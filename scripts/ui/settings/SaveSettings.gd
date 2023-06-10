extends Button

func _pressed():
	SSP.save_settings()

func _exit_tree():
	if !OS.has_feature("debug"):
		SSP.save_settings()

func _ready():
	visible = OS.has_feature("debug")
