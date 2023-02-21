extends BaseManager
class_name ObjectManager

@export_node_path("Node3D") var origin_path
@onready var origin = get_node(origin_path)

func _ready():
	pass
