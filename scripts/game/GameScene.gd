extends Node3D
class_name GameScene

@export var sync_manager: NodePath
@export var note_manager: NodePath
@export var hud_manager: NodePath
@export var camera: NodePath

func _ready():
	sync_manager.get_node()