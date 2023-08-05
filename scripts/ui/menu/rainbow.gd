extends Control

export(float) var saturation = 0.65
export(float) var value = 1
export(float) var alpha = 1

func _process(delta):
	modulate = Color.from_hsv(Rhythia.rainbow_t*0.1,saturation,value,alpha)
