extends Node

var player_name:String = "Player"

@onready var api:MultiplayerAPI = get_tree().get_multiplayer()
@onready var peer:MultiplayerPeer = ENetMultiplayerPeer.new()

func _ready():
	api.connected_to_server.connect(connected)
	api.server_disconnected.connect(disconnected)
	api.peer_connected.connect(peer_added)
	api.peer_disconnected.connect(peer_removed)

func check_connected():
	return peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED

func host(port:int=12345) -> Error:
	if check_connected():
		peer.close()
	var err = peer.create_server(port)
	print("Hosting a server on port %s" % port)
	api.multiplayer_peer = peer
	if err == OK:
		connected()
	return err

func join(address:String="127.0.0.1",port:int=12345) -> Error:
	if check_connected():
		peer.close()
	var err = peer.create_client(address,port)
	print("Joining a server on port %s" % port)
	api.multiplayer_peer = peer
	return err

func leave():
	peer.close()

class Player:
	var id:int
	var name:String
	var connected:bool = true

signal player_added
signal player_removed

var local_player:Player
var players:Dictionary = {}

@rpc("authority","call_local","reliable")
func start(mapset_id:String,map_index:int=0):
	var mapset = SoundSpacePlus.mapsets.get_by_id(mapset_id)
	var scene = SoundSpacePlus.load_game_scene(SoundSpacePlus.GameType.MULTI,mapset,map_index)
	get_tree().change_scene_to_node(scene)

@rpc("any_peer","call_remote","reliable")
func register_player(_name:String):
	var id = api.get_remote_sender_id()
	if players.has(id): return
	print("Register player %s %s" % [id,_name])
	var player = Player.new()
	player.id = id
	player.name = _name
	players[id] = player

func connected():
	print("Connected to a server")
	players = {}
	local_player = Player.new()
	local_player.id = api.get_unique_id()
	local_player.name = player_name
func disconnected():
	print("Disconnected from server")
	local_player.connected = false
	local_player = null
	players = {}

func peer_added(id:int):
	print("Peer connected %s" % id)
	rpc_id(id,"register_player",local_player.name)
func peer_removed(id:int):
	print("Peer disconnected %s" % id)
	if !players.has(id): return
	players.get(id).connected = false
	players.erase(id)
