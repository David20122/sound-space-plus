extends Viewport

@onready var _world_2d = find_world_2d()
@onready var _world_3d = find_world_3d()

@onready var origin:XROrigin3D = preload("res://prefabs/xr/Origin.tscn").instantiate()

func _ready():
	add_child(origin)
	
	use_xr = true
	
	handle_input_locally = false
	
	world_2d = _world_2d
	world_3d = _world_3d
