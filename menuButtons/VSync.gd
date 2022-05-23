extends CheckBox

func _pressed():
	if pressed != OS.vsync_enabled:
		OS.vsync_enabled = pressed

func _ready():
	pressed = OS.vsync_enabled
