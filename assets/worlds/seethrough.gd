extends Spatial

func _ready():
	get_tree().get_root().set_transparent_background(true)
	OS.window_per_pixel_transparency_enabled = true
	OS.window_fullscreen = false
	OS.window_borderless = true
	get_viewport().transparent_bg = true
