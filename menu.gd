extends Node

func _ready():
	get_tree().paused = false
	$BlackFade.visible = true
	$BlackFade.color = Color(0,0,0,black_fade)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

var black_fade_target:bool = false
var black_fade:float = 1

func _process(delta):
	if black_fade_target && black_fade != 1:
		black_fade = min(black_fade + (delta/0.75),1)
		$BlackFade.color = Color(0,0,0,black_fade)
	elif !black_fade_target && black_fade != 0:
		black_fade = max(black_fade - (delta/0.75),0)
		$BlackFade.color = Color(0,0,0,black_fade)
		
