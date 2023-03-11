extends AnimationPlayer

@export var type:String = ""

func _ready():
	play("anim")

func _input(event):
	match type.to_lower():
		"nametag":
			play("anim")
