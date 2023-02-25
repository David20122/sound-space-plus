extends ResourcePlus
class_name EnvironmentPlus

@export var world:PackedScene

func _init(_world:PackedScene=null):
	world = _world

func load_world():
	var node = world.instantiate()
	return node
