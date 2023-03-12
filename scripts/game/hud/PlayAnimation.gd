extends AnimationPlayer

@export var type:String = ""

func _ready():
	play("anim")

func _input(event):
	match type.to_lower():
		"nametag":
			if !event.is_action_pressed("playerlist"): return
			play("anim")
