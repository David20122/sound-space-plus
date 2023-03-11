extends Node3D
class_name MultiScene

var mods:Mods = Mods.new()
var mapset:Mapset
var map_index:int

@onready var player_parent = $Players
@onready var local_player = $Players/LocalPlayer

func _ready():
	local_player.network_player = Multiplayer.local_player
	local_player.name = str(Multiplayer.api.get_unique_id())
	local_player.get_node_or_null("Origin/Player/Cursor/DisplayName").text = Multiplayer.player_name
	local_player.set_multiplayer_authority(Multiplayer.api.get_unique_id())
	
	local_player.get_node("SyncManager").connect("finished",func(): rpc("ended"))
	local_player.get_node("Origin/Player").connect("failed",func(): rpc("ended"))
	
	for player in Multiplayer.lobby.players.values():
		if player == Multiplayer.local_player: continue
		var scene = preload("res://prefabs/game/multi/MultiGameScene.tscn").instantiate()
		scene.root_path = get_path()
		scene.network_player = player
		scene.name = str(player.id)
		scene.set_multiplayer_authority(player.id)
		scene.translate(Vector3(0,0,3.5))
		var cursor:MeshInstance3D = scene.get_node("Origin/Player/Cursor/Real")
		cursor.set("material_override/albedo_color", player.color)
		print(
			"{name}'s player color is {color}".format({
				"name": player.nickname,
				"color": str(player.color)
			})
		)
		cursor.transparency = 0.8
		cursor.scale = Vector3.ONE * 0.3
		player_parent.add_child(scene)

var players_ended = {}
@rpc("any_peer","call_local","reliable")
func ended():
	if !Multiplayer.api.is_server(): return
	var id = Multiplayer.api.get_remote_sender_id()
	players_ended[id] = true
	if players_ended.has_all(Multiplayer.lobby.players.keys()):
		rpc("finish")

@rpc("authority","call_local","reliable")
func finish():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

var players_done = {}
@rpc("any_peer","call_local","reliable")
func done():
	if !Multiplayer.api.is_server(): return
	var id = Multiplayer.api.get_remote_sender_id()
	players_done[id] = true
	if players_done.has_all(Multiplayer.lobby.players.keys()):
		rpc("start")

@rpc("authority","call_local","reliable")
func start():
	local_player.sync_manager.start(-2)
