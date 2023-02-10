extends Node3D

func _ready():
	get_tree().get_root().set_transparent_background(true)
	OS.window_per_pixel_transparency_enabled = true
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (false) else Window.MODE_WINDOWED
	get_window().borderless = true
	get_viewport().transparent_bg = true
