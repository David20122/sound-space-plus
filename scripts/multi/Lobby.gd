extends Node
class_name Lobby

signal player_added
signal player_removed

@export var host:Player
@onready var player_container = $PlayerContainer

var players:Dictionary:
	get:
		var dict = {}
		for player in player_container.get_children():
			if player is Player:
				dict[player.id] = player
		return dict
func create_player(id:int):
	var player = preload("res://prefabs/multi/Player.tscn").instantiate()
	player.id = id
	player_container.add_child(player)
	return player

@rpc("authority","call_local","reliable")
func start(mapset_id:String,map_index:int=0):
	var mapset = SoundSpacePlus.mapsets.get_by_id(mapset_id)
	var scene = SoundSpacePlus.load_game_scene(SoundSpacePlus.GameType.MULTI,mapset,map_index)
	get_tree().change_scene_to_node(scene)
