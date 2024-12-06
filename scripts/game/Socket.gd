extends Node

# URL for the WebSocket server
export var SOCKET_URL = "ws://127.0.0.1:36331"

# WebSocket client instance
var _wsClient = WebSocketClient.new()

# Maximum number of reconnection attempts (-1 for unlimited retries)
export var max_retries = -1
var retry_count = 0
var reconnect_delay = 2.0 # Delay between reconnection attempts in seconds

### **Lifecycle Methods**

# Called when the node is added to the scene
func _ready():
	print("Initializing Socket Module")
	initialize_socket()

# Initializes the WebSocket and connects signals
func initialize_socket():
	"""
	Initializes the WebSocket module, connects signals for WebSocket events,
	and attempts to establish a connection to the server.

	- Signals:
	  - `connection_closed`: Handles when the connection is closed.
	  - `connection_error`: Handles connection errors.
	  - `connection_established`: Handles successful connection establishment.
	  - `data_received`: Handles incoming data.
	"""
	_wsClient = WebSocketClient.new()
	_wsClient.connect("connection_closed", self, "_on_connection_closed")
	_wsClient.connect("connection_error", self, "_on_connection_closed")
	_wsClient.connect("connection_established", self, "_on_connection_established")
	_wsClient.connect("data_received", self, "_on_data_received")
	
	var err = _wsClient.connect_to_url(SOCKET_URL)
	if err != OK:
		print("Error while connecting:", err)
		set_physics_process(false)

# Called every frame
func _physics_process(delta):
	"""
	Polls the WebSocket client for updates. This keeps the connection
	alive and processes incoming/outgoing packets.
	"""
	_wsClient.poll()


### **Signal Handlers**

# Handles the connection being closed
func _on_connection_closed(was_clean = false):
	print("Connection Closed. Clean:", was_clean)
	set_physics_process(false)
	if max_retries == -1 or retry_count < max_retries:
		print("Attempting to reconnect in", reconnect_delay, "seconds...")
		retry_count += 1
		yield (get_tree().create_timer(reconnect_delay), "timeout")
		initialize_socket()
	else:
		print("Maximum reconnection attempts reached. Giving up.")

# Handles the connection being successfully established
func _on_connection_established(proto = ""):
	"""
	Handles successful WebSocket connection establishment.

	- Parameters:
	  - `proto` (String): The protocol used for the connection.
	"""
	
	send(
		JSON.print(
			{
				# Identifiers
				"pid": OS.get_process_id(),
				"start_arguments": OS.get_cmdline_args(),
				"type": "game_start",
			}
		))
	print("Connection Established", proto)

# Handles data received from the WebSocket
func _on_data_received():
	"""
	Handles incoming data from the WebSocket connection.

	- Parses the received data as JSON and extracts the `result` field.
	"""
	var payload = JSON.parse(_wsClient.get_peer(1).get_packet().get_string_from_utf8()).result
	print("RECEIVED:", payload)


### **Sending Data**

# Sends a packet via the WebSocket
func send(packet = ""):
	"""
	Sends a JSON-formatted packet to the WebSocket server.

	- Parameters:
	  - `packet` (String): The JSON-formatted data to send.
	"""
	_wsClient.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	_wsClient.get_peer(1).put_packet(packet.to_utf8())

# Sends a "map_start" event
func send_map_start():
	"""
	Sends a message indicating that a map has started.
	Includes details about the selected song and related replay data.
	"""
	send(
		JSON.print(
			{
				# Identifiers
				"pid": OS.get_process_id(),
				"start_arguments": OS.get_cmdline_args(),
				"type": "map_start",
				
				# Basis
				"song_name": Rhythia.selected_song.name,
				"song_id": Rhythia.selected_song.id,
				"song_path": Rhythia.selected_song.filePath,
				"replay_path": Rhythia.replay.file.get_path_absolute(),
				
				
				# Mods
				"start_offset": Rhythia.start_offset,
				"note_hitbox_size": Rhythia.note_hitbox_size,
				"hitwindow_ms": Rhythia.hitwindow_ms,
				"custom_speed": Rhythia.custom_speed,
				"health_model": Rhythia.health_model,
				"grade_system": Rhythia.grade_system,
				"visual_mode": Rhythia.visual_mode,
				"invert_mouse": Rhythia.invert_mouse,
				"disable_pausing": Rhythia.disable_pausing,
				"speed_hitwindow": Rhythia.speed_hitwindow,
				"restart_on_death": Rhythia.restart_on_death,
				"mod_extra_energy": Rhythia.mod_extra_energy,
				"mod_no_regen": Rhythia.mod_no_regen,
				"mod_speed_level": Rhythia.mod_speed_level,
				"mod_nofail": Rhythia.mod_nofail,
				"mod_mirror_x": Rhythia.mod_mirror_x,
				"mod_mirror_y": Rhythia.mod_mirror_y,
				"mod_nearsighted": Rhythia.mod_nearsighted,
				"mod_ghost": Rhythia.mod_ghost,
				"mod_sudden_death": Rhythia.mod_sudden_death,
				"mod_chaos": Rhythia.mod_chaos,
				"mod_earthquake": Rhythia.mod_earthquake,
				"mod_flashlight": Rhythia.mod_flashlight,
				"mod_hardrock": Rhythia.mod_hardrock,
			}
		)
	)

# Sends a "menu_state" event
func send_menu_state(menu_state = 0):
	"""
	Sends a message indicating the current state of the menu.

	- Parameters:
	  - `menu_state` (int): Represents the current state of the menu.
	"""
	send(
		JSON.print(
			{
				"pid": OS.get_process_id(),
				"start_arguments": OS.get_cmdline_args(),
				"type": "menu_state",
				"state": menu_state
			}
		)
	)

# Sends a "map_end" event
func send_map_end(end_type = 0):
	"""
	Sends a message indicating that a map has ended.
	Includes performance statistics and related song information.

	- Parameters:
	  - `end_type` (int): Type of map end event (e.g., success, failure).
	"""
	send(
		JSON.print(
			{
				# Identifiers
				"pid": OS.get_process_id(),
				"start_arguments": OS.get_cmdline_args(),
				"type": "map_end",
				"end_type": end_type,
				
				# Basis
				"song_name": Rhythia.selected_song.name,
				"song_id": Rhythia.selected_song.id,
				"song_path": Rhythia.selected_song.filePath,
				"replay_path": Rhythia.replay.file.get_path_absolute(),
				
				
				# Mods
				"start_offset": Rhythia.start_offset,
				"note_hitbox_size": Rhythia.note_hitbox_size,
				"hitwindow_ms": Rhythia.hitwindow_ms,
				"custom_speed": Rhythia.custom_speed,
				"health_model": Rhythia.health_model,
				"grade_system": Rhythia.grade_system,
				"visual_mode": Rhythia.visual_mode,
				"invert_mouse": Rhythia.invert_mouse,
				"disable_pausing": Rhythia.disable_pausing,
				"speed_hitwindow": Rhythia.speed_hitwindow,
				"restart_on_death": Rhythia.restart_on_death,
				"mod_extra_energy": Rhythia.mod_extra_energy,
				"mod_no_regen": Rhythia.mod_no_regen,
				"mod_speed_level": Rhythia.mod_speed_level,
				"mod_nofail": Rhythia.mod_nofail,
				"mod_mirror_x": Rhythia.mod_mirror_x,
				"mod_mirror_y": Rhythia.mod_mirror_y,
				"mod_nearsighted": Rhythia.mod_nearsighted,
				"mod_ghost": Rhythia.mod_ghost,
				"mod_sudden_death": Rhythia.mod_sudden_death,
				"mod_chaos": Rhythia.mod_chaos,
				"mod_earthquake": Rhythia.mod_earthquake,
				"mod_flashlight": Rhythia.mod_flashlight,
				"mod_hardrock": Rhythia.mod_hardrock,
			}
		)
	)
