extends Node3D
class_name GameScene

@export var sync_manager_path: NodePath
@export var note_manager_path: NodePath
@export var hud_manager_path: NodePath
@export var camera_path: NodePath

@export var environment_path: NodePath

@onready var sync_manager = get_node(sync_manager_path)
@onready var note_manager = get_node(note_manager_path)
@onready var hud_manager = get_node(hud_manager_path)
@onready var camera = get_node(camera_path)

@onready var environment = get_node(environment_path)

func _ready():
	pass
