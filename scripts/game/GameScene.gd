extends Node3D
class_name GameScene

var mods:Mods
var settings:Settings

var mapset:Mapset
var map_index:int
var map:Map

@export_category("Game Managers")
@export var sync_manager_path:NodePath
@onready var sync_manager:SyncManager = get_node(sync_manager_path)
@export var object_manager_path:NodePath
@onready var object_manager:ObjectManager = get_node(object_manager_path)

@export_category("Other Nodes")
@export_node_path("Node3D") var origin_path
@onready var origin:Node3D = get_node(origin_path)
@export var player_path:NodePath
@onready var player:PlayerObject = get_node(player_path)
@onready var local_player:bool = player.local_player

func setup_managers():
	sync_manager.prepare(self)
	object_manager.prepare(self)

func _ready():
	map = mapset.maps[map_index]
	
	if sync_manager is AudioSyncManager: sync_manager.audio_stream = mapset.audio
	sync_manager.playback_speed = mods.speed
	
	setup_managers()
	sync_manager.connect("finished",Callable(self,"finish"))
	
	call_deferred("ready")

func ready():
	pass
func finish(_failed:bool=false):
	pass
