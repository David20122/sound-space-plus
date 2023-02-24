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
@export_node_path("Node3D") var origin_path
@export_node_path("Node3D") var world_path
@export var player_path:NodePath

@onready var sync_manager:SyncManager = get_node(sync_manager_path)
@onready var object_manager:ObjectManager = get_node(object_manager_path)
@onready var hud_manager:HUDManager = get_node(hud_manager_path)

@onready var origin:Node3D = get_node(origin_path)
@onready var world_parent:Node3D = get_node(world_path)
@onready var player:PlayerObject = get_node(player_path)

func _ready():
	map = mapset.maps[map_index]
	print("Now playing %s [%s] - %s" % [mapset.name, map.name, mapset.id])
	print("This is a SSPM v%s map" % mapset.format)
	
#	var world = SoundSpacePlus.worlds.get_by_id("tunnel")
	var world = null
	if world != null:
		var world_node = world.world.instance()
		world_parent.add_child(world_node)
	
	object_manager.prepare(origin)
	object_manager.call_deferred("build_map",map)
	
	sync_manager.audio_stream = mapset.audio
	sync_manager.call_deferred("start",-2)
	sync_manager.connect("finished",Callable(self,"finish"))
	
	player.connect("failed",Callable(self,"finish").bind(true))

var finished:bool = false
func finish(failed:bool=false):
	if finished: return
	finished = true
	print("failed: %s" % failed)
	if failed:
		print("fail animation")
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(sync_manager,"playback_speed",0,2)
		tween.play()
		await tween.finished
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
