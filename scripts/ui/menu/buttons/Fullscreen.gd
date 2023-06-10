extends CheckBox

func _pressed():
	if pressed != OS.window_fullscreen:
		OS.window_fullscreen = pressed

func _ready():
	visible = OS.has_feature("pc")
#	OS.window_fullscreen = true
#	pressed = true
