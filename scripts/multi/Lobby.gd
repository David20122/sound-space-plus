extends Node
class_name Lobby

@export var mods:Mods

@export var map_id:String:
	get: return map_id
	set(value):
		Multiplayer.local_player.has_map = value in SoundSpacePlus.mapsets.get_ids()
		map_id = value

@export var host:int = 1
@onready var player_container = $PlayerContainer

var players:Dictionary:
	get:
		var dict = {}
		for player in player_container.get_children():
			if player is Player:
				dict[player.id] = player
		return dict

@rpc("authority","call_local","reliable")
func start(map_index:int=0):
	var mapset = SoundSpacePlus.mapsets.get_by_id(map_id)
	var scene = SoundSpacePlus.load_game_scene(SoundSpacePlus.GameType.MULTI,mapset,map_index)
	get_tree().change_scene_to_node(scene)

@rpc("authority","call_local","reliable")
func set_mods(data:Dictionary):
	mods = Mods.new()
	mods.data = data
