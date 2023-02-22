extends GameObject
class_name PlayerObject

@export_category("Configuration")
@export var local_player:bool = false

@export_category("Node Paths")
@export_node_path("Camera3D") var camera_path
@onready var camera:Camera3D = get_node(camera_path)
@export_node_path("Node3D") var cursor_path
@onready var cursor:Node3D = get_node(cursor_path)

var cursor_position:Vector2

func _ready():
	if local_player: camera.make_current()
	
