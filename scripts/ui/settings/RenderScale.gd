extends SpinBox

func _on_Scale_value_changed(value):
	var resolution = OS.window_size
	if OS.window_fullscreen: resolution = OS.get_screen_size()
	SSP.render_scale = value
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_IGNORE, resolution * value)

func viewport_size_changed():
	var resolution = OS.window_size
	if OS.window_fullscreen: resolution = OS.get_screen_size()
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_IGNORE, resolution * SSP.render_scale)
	
func _ready():
	get_tree().get_root().connect("size_changed", self, "viewport_size_changed")
	connect("changed", self, "_on_Scale_value_changed")
	value = SSP.render_scale
	viewport_size_changed()
