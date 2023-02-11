extends Node3D
class_name GameScene

@export var sync_manager_path: NodePath
@export var note_manager_path: NodePath
@export var hud_manager_path: NodePath
@export var camera_path: NodePath

var sync_manager
var note_manager
var hud_manager
var camera

func _ready():
	sync_manager = get_node(sync_manager_path)
	note_manager = get_node(note_manager_path)
	hud_manager = get_node(hud_manager_path)
	camera = get_node(camera_path)