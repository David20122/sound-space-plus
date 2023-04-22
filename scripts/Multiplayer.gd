extends Node

const MP_VERSION = 3
const MP_PORT = 12345

var lobby:Lobby
var server_ip:String

var player_name:String = "Player"
var player_color:Color = Color(1,1,1,1)

@onready var api:SceneMultiplayer = get_tree().get_multiplayer()
@onready var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@onready var upnp:UPNP = UPNP.new()

func mp_print(string):
	print("%s : " % api.get_unique_id(),string)

func _ready():
	upnp.discover()

	api.auth_callback = auth_callback
	api.peer_authenticating.connect(peer_authenticating)
	api.peer_authentication_failed.connect(peer_auth_failed)

	api.connected_to_server.connect(connected)
	api.server_disconnected.connect(disconnected)

	api.peer_connected.connect(peer_added)
	api.peer_disconnected.connect(peer_removed)

func check_connected():
	return lobby and local_player and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED
func check_host():
	return check_connected() and lobby.host == api.get_unique_id()

func join(address:String="127.0.0.1",port:int=MP_PORT) -> Error:
	if check_connected():
		peer.close()
	var err = peer.create_client(address,port)
	server_ip = address
	mp_print("Joining a server %s on port %s" % [address,port])
	api.multiplayer_peer = peer
	return err
func leave():
	peer.close()

var local_player:Player:
	get:
		if lobby.players: return lobby.players.get(api.get_unique_id())
		return null

func send_auth(id:int):
	var packet = PackedByteArray()
	packet.resize(128)
	var player_data = {
		nickname = player_name,
		color = player_color
	}
	packet.encode_u8(0,MP_VERSION)
	packet.encode_var(1,player_data)
	api.send_auth(id,packet)
func auth_callback(id:int,data:PackedByteArray):
	if id != 1:
		mp_print("Auth request not from server - something isn't right (%s)" % id)
		return
	var version = data.decode_u8(0)
	mp_print("Auth request from server running version %s" % version)
	if version != MP_VERSION:
		mp_print("Version mismatch - we're running %s" % MP_VERSION)
		peer.close()
		return
	mp_print("Replying to auth request")
	send_auth(id)
	api.complete_auth(id)
	return

func create_lobby():
	get_tree().paused = true
	lobby = preload("res://prefabs/multi/Lobby.tscn").instantiate()
	lobby.set_multiplayer_authority(1)
	add_child(lobby)
	get_tree().paused = false

func connected():
	mp_print("Connected to a server")
	create_lobby()
func disconnected():
	mp_print("Disconnected from server")
	get_tree().paused = true
	if lobby:
		lobby.queue_free()
		lobby = null
	get_tree().paused = false

func peer_authenticating(id:int):
	mp_print("Peer attempting to connect %s" % id)
func peer_auth_failed(id:int):
	mp_print("Peer failed to connect %s" % id)
func peer_added(id:int):
	mp_print("Peer connected %s" % id)
func peer_removed(id:int):
	mp_print("Peer disconnected %s" % id)
	peer.close()
