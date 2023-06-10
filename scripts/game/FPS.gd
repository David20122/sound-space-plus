extends Label

func _process(delta):
	text = String(Engine.get_frames_per_second())
