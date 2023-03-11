extends Node

const MP_VERSION = 1
const MP_PORT = 12345

var lobby:Lobby

var player_name:String = "Player"
var player_color:Color = Color(1,1,1,1)

@onready var api:SceneMultiplayer = get_tree().get_multiplayer()
@onready var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@onready var upnp:UPNP = UPNP.new()

func mp_print(string):
	print("%s : " % api.get_unique_id(),string)

func _ready():
	upnp.discover()
	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		print(upnp.add_port_mapping(MP_PORT,MP_PORT,"Sound Space Plus","UDP"))
		print(upnp.add_port_mapping(MP_PORT,MP_PORT,"Sound Space Plus","TCP"))
	
	api.auth_callback = auth_callback
	api.peer_authenticating.connect(peer_authenticating)
	api.peer_authentication_failed.connect(peer_auth_failed)
	
	api.connected_to_server.connect(connected)
	api.server_disconnected.connect(disconnected)
	
	api.peer_connected.connect(peer_added)
	api.peer_disconnected.connect(peer_removed)
func _exit_tree():
	upnp.delete_port_mapping(MP_PORT,"UDP")
	upnp.delete_port_mapping(MP_PORT,"TCP")

func check_connected():
	return lobby and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func host(port:int=MP_PORT) -> Error:
	if check_connected():
		peer.close()
	var err = peer.create_server(port)
	mp_print("Hosting a server on port %s" % port)
	api.multiplayer_peer = peer
	print(err)
	if err == OK:
		connected()
		lobby.create_player(1)
		local_player.nickname = player_name
		local_player.color = player_color
	return err
func join(address:String="127.0.0.1",port:int=MP_PORT) -> Error:
	if check_connected():
		peer.close()
	var err = peer.create_client(address,port)
	mp_print("Joining a server %s on port %s" % [address,port])
	api.multiplayer_peer = peer
	return err
func leave():
	peer.close()

var local_player:Player:
	get:
		return lobby.players[api.get_unique_id()]

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
	mp_print("Received auth packet")
	if id == 1:
		var version = data.decode_u8(0)
		if version != MP_VERSION:
			peer.close()
			return
		api.complete_auth(1)
		return
	if !api.is_server(): return
	var player_data:Dictionary = data.decode_var(1)
	var player = lobby.create_player(id)
	player.nickname = player_data.get("nickname","Player")
	player.color = player_data.get("color",Color.WHITE)
	api.complete_auth(id)
	rpc_id(id,"local_player_created")

func connected():
	mp_print("Connected to a server")
	lobby = preload("res://prefabs/multi/Lobby.tscn").instantiate()
	lobby.set_multiplayer_authority(1)
	add_child(lobby)
func disconnected():
	mp_print("Disconnected from server")
	lobby.queue_free()
	lobby = null

func peer_authenticating(id:int):
	mp_print("Peer attempting to connect %s" % id)
	send_auth(id)
func peer_auth_failed(id:int):
	mp_print("Peer failed to connect %s" % id)
func peer_added(id:int):
	mp_print("Peer connected %s" % id)
func peer_removed(id:int):
	mp_print("Peer disconnected %s" % id)
	lobby.players[id].queue_free()
