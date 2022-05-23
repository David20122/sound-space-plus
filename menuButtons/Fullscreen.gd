extends CheckBox

func _pressed():
	if pressed != OS.window_fullscreen:
		OS.window_fullscreen = pressed

func _ready():
	pressed = OS.window_fullscreen
