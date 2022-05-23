extends MeshInstance

export(float) var spin_speed = 3.14/7.5

var gottamovespeed:float = 45

func _process(delta):
	rotate_z(delta*spin_speed*-.05*gottamovespeed)
	gottamovespeed = max(gottamovespeed - (delta*gottamovespeed), 1)

func _ready():
	_process(1.5)
