extends Node

# URL for the WebSocket server
export var SOCKET_URL = "ws://127.0.0.1:3000"

# WebSocket client instance
var _wsClient = WebSocketClient.new()

### **Lifecycle Methods**

# Called when the node is added to the scene
func _ready():
	"""
	Initializes the WebSocket module, connects signals for WebSocket events, 
	and attempts to establish a connection to the server.

	- Signals:
	  - `connection_closed`: Handles when the connection is closed.
	  - `connection_error`: Handles connection errors.
	  - `connection_established`: Handles successful connection establishment.
	  - `data_received`: Handles incoming data.
	"""
	print("Initializing Socket Module")
	_wsClient.connect("connection_closed", self, "_on_connection_closed")
	_wsClient.connect("connection_error", self, "_on_connection_closed")
	_wsClient.connect("connection_established", self, "_on_connection_established")
	_wsClient.connect("data_received", self, "_on_data_received")
	
	var err = _wsClient.connect_to_url(SOCKET_URL)
	if err != OK:
		print("Error while connecting:", err)
		set_process(false)

# Called every frame
func _process(delta):
	"""
	Polls the WebSocket client for updates. This keeps the connection
	alive and processes incoming/outgoing packets.
	"""
	_wsClient.poll()


### **Signal Handlers**

# Handles the connection being closed
func _on_connection_closed(was_clean = false):
	"""
	Handles the WebSocket connection closure.

	- Parameters:
	  - `was_clean` (bool): Indicates if the connection was closed cleanly.
	"""
	print("Connection Closed")
	set_process(false)

# Handles the connection being successfully established
func _on_connection_established(proto = ""):
	"""
	Handles successful WebSocket connection establishment.

	- Parameters:
	  - `proto` (String): The protocol used for the connection.
	"""
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
				"pid": OS.get_process_id(),
				"start_arguments": OS.get_cmdline_args(),
				"type": "map_start",
				"song_name": Rhythia.selected_song.name,
				"song_id": Rhythia.selected_song.id,
				"song_path": Rhythia.selected_song.filePath,
				"replay_path": Rhythia.replay.file.get_path_absolute()
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
				"pid": OS.get_process_id(),
				"start_arguments": OS.get_cmdline_args(),
				"type": "map_end",
				"end_type": end_type,
				"just_ended_song": Rhythia.just_ended_song,
				"song_end_hits": Rhythia.song_end_hits,
				"song_end_misses": Rhythia.song_end_misses,
				"song_end_total_notes": Rhythia.song_end_total_notes,
				"song_end_position": Rhythia.song_end_position,
				"song_end_length": Rhythia.song_end_length,
				"song_end_type": Rhythia.song_end_type,
				"song_end_combo": Rhythia.song_end_combo,
				"song_name": Rhythia.selected_song.name,
				"song_id": Rhythia.selected_song.id,
				"song_path": Rhythia.selected_song.filePath,
				"replay_path": Rhythia.replay.file.get_path_absolute()
			}
		)
	)
