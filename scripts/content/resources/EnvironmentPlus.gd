extends ResourcePlus
class_name EnvironmentPlus

@export_file("*.tscn") var world_path
var world:PackedScene

func _init(_world:String=""):
	world_path = _world
	if FileAccess.file_exists(world_path):
		world = load(world_path) as PackedScene
	else:
		broken = true
