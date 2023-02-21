extends Node3D
class_name GameScene

var mapset:Mapset
var map_index:int

@export_category("Game Managers")
@export var sync_manager_path:NodePath
@export var object_manager_path:NodePath
@export var hud_manager_path:NodePath

@export_category("Player Objects")
@export_node_path("Camera3D") var camera_path
@export_node_path("WorldEnvironment") var environment_path

@onready var sync_manager:SyncManager = get_node(sync_manager_path)
@onready var object_manager:ObjectManager = get_node(object_manager_path)
@onready var hud_manager:HUDManager = get_node(hud_manager_path)

@onready var camera:Camera3D = get_node(camera_path)
@onready var environment:WorldEnvironment = get_node(environment_path)

func _ready():
	pass
