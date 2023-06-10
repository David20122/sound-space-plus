extends CheckBox

func _pressed():
	if pressed != OS.vsync_via_compositor:
		OS.vsync_via_compositor = pressed

func _ready():
	visible = OS.has_feature("pc")
	pressed = OS.vsync_via_compositor
