extends Node3D
class_name GameScene

var mapset:Mapset
var map_index:int
var map:Map

@export_category("Game Managers")
@export var sync_manager_path:NodePath
@export var object_manager_path:NodePath
@export var hud_manager_path:NodePath

@export_category("Other Nodes")
@export_node_path("WorldEnvironment") var environment_path
@export_node_path("Node3D") var player_path

@onready var sync_manager:SyncManager = get_node(sync_manager_path)
@onready var object_manager:ObjectManager = get_node(object_manager_path)
@onready var hud_manager:HUDManager = get_node(hud_manager_path)

@onready var environment:WorldEnvironment = get_node(environment_path)
@onready var local_player:PlayerObject = get_node(player_path) as PlayerObject

func _ready():
	map = mapset.maps[map_index]
	print("Now playing %s [%s] - %s" % [mapset.name, map.name, mapset.id])
	print("This is a SSPM v%s map" % mapset.format)
	
	object_manager.build_map(map)
	
	sync_manager.audio_stream = mapset.audio
	sync_manager.call_deferred("start",-1)
	sync_manager.connect("finished",Callable(self,"finish"))

func finish(failed:bool=false):
	print("Finished")
