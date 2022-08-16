class_name DiscordRPC extends Node

signal rpc_ready(user)
signal authorized(code)
signal authenticated(expires)
signal guild_status(id, name, icon_url)
signal guild_create(id, name)
signal channel_create(id, name, type)
signal voice_channel_select(channel_id, guild_id)
signal voice_state_create(voice_state)
signal voice_state_update(voice_state)
signal voice_state_delete(voice_state)
signal voice_settings_update(voice_settings)
signal voice_connection_status(state, hostname, pings, average_ping, last_ping)
signal speaking_start(channel_id, user_id)
signal speaking_stop()
signal message_create(message)
signal message_update(message)
signal message_delete(message)
signal notification_create(channel_id, message, icon_url, title, body)
signal activity_join(secret)
signal activity_spectate(secret)
signal activity_join_request(user)
signal raw_data(data)
signal rpc_closed()
signal rpc_error(code)


enum {
	DISCONNECTED,
	CONNECTING,
	CONNECTED,
	DISCONNECTING
}

enum {
	ERR_UNSUPPORTED = 49,
	ERR_HANDSHAKE,
	ERR_CLIENT_NOT_FOUND
}

const VERSION: int = 1
const DISCORD_API_ENDPOINT: String = "https://discord.com/api/%s"

var _ipc: IPC setget __set
var _modules: Dictionary setget __set

var status: int = DISCONNECTED setget __set
var client_id: int setget __set
var scopes: PoolStringArray setget __set

func _init() -> void:
	_ipc = IPC.new()
	self._ipc.connect("data_recieved", self, "_on_data")
	self.install_module(RichPresenceModule.new())
	self.set_process(false)

func establish_connection(_client_id: int) -> void:
	if (self.is_connected_to_client()):
		push_error("This DiscordRPC instance is already in an active connection")
		return

	if (not self.is_supported()):
		push_error("IPC error: Unsuported platform")
		emit_signal("rpc_error", ERR_UNSUPPORTED)
		return

	if (not self.is_inside_tree()):
		push_error("DiscordRPC isn't inside a scene tree")
		emit_signal("rpc_error", ERR_UNCONFIGURED)
		return

	client_id = _client_id
	status = CONNECTING
	for i in range(10):
		var path = IPC.get_pipe_path(i)
		if (self._ipc.open(path) == OK):
			self._ipc.setup()
			self._handshake()
			self.set_process(true)
			return
		self._ipc.close()
	self.emit_signal("rpc_error", ERR_CLIENT_NOT_FOUND)
	self.shutdown()

func is_connected_to_client() -> bool:
	return self._ipc and self._ipc.is_open() and self.status != DISCONNECTED

func authorize(_scopes: PoolStringArray, secret: String) -> void:
	var request: IPCPayload = IPCUtil.AuthorizePayload.new(self.client_id, _scopes)
	var response: IPCPayload = yield(self._ipc.send(request), "completed")
	if (not response.is_error()):
		var code: String = response.data["code"]
		var auth_token: String = yield(self.get_auth_token(code, secret), "completed")
		if (not auth_token.empty()):
			self.emit_signal("authorized", auth_token)
			self.authenticate(auth_token)

func authenticate(access_token: String) -> void:
	var request: IPCPayload = IPCUtil.AuthenticatePayload.new(access_token)
	var response: IPCPayload = yield(self._ipc.send(request), "completed")
	if (not response.is_error()):
		scopes = response.data["scopes"]
		self.emit_signal("authenticated", response.data["expires"])

func get_auth_token(authorize_code: String, secret: String, redirect_url: String = "http://127.0.0.1") -> String:
	var http_request: HTTPRequest = HTTPRequest.new()
	http_request.use_threads = OS.can_use_threads()
	var url: String = DISCORD_API_ENDPOINT % "oauth2/token"
	var headers: PoolStringArray = ["Content-Type: application/x-www-form-urlencoded"]
	var data: Dictionary = {
		"client_id": self.client_id,
		"client_secret": secret,
		"grant_type": "authorization_code",
		"code": authorize_code,
		"redirect_uri": redirect_url
	}

	self.add_child(http_request)
	http_request.request(
		url,
		headers,
		true,
		HTTPClient.METHOD_POST,
		URLUtil.dict_to_url_encoded(data)
	)
	var response: Array = yield(http_request, "request_completed")
	var result: int = response[0]
	var code: int = response[1]
	var body: PoolByteArray = response[3]

	http_request.queue_free()

	return parse_json(body.get_string_from_utf8()).get("access_token", "")

func subscribe(event: String, arguments: Dictionary = {}) -> void:
	self._ipc.send(IPCUtil.SubscribePayload.new(event, arguments))

func unsubscribe(event: String, arguments: Dictionary = {}) -> void:
	self._ipc.send(IPCUtil.UnsubscribePayload.new(event, arguments))

func shutdown() -> void:
	status = DISCONNECTING
	self._ipc.close()
	status = DISCONNECTED
	self.set_process(false)
	self.emit_signal("rpc_closed")

func install_module(module: IPCModule) -> void:
	if (not self._modules.has(module.name)):
		module.initilize(self._ipc)
		self._modules[module.name] = module

func get_module(name: String) -> IPCModule:
	return self._modules.get(name)

func uninstall_module(name: String) -> void:
	# warning-ignore:return_value_discarded
	self._modules.erase(name)

func ipc_call(function: String, arguments: Array = []):
	for module in self._modules.values():
		if (function in module.get_functions()):
			return module.callv(function, arguments)
	push_error("Calling non-existant function \"%s\" via ipc_call" % function)
	return null

func _handshake() -> void:
	if (self.status == CONNECTED):
		push_error("Already handshaked !")
		return
	var request: IPCPayload = IPCUtil.HandshakePayload.new(VERSION, self.client_id)
	var response: IPCPayload = yield(self._ipc.send(request), "completed")
	if (response.op_code != IPCPayload.OpCodes.CLOSE and not response.is_error()):
		status = CONNECTED
		self.emit_signal("rpc_ready", response.data["user"])
		return
	self.emit_signal("rpc_error", ERR_HANDSHAKE)
	self.shutdown()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			self.shutdown()

func _process(_delta: float) -> void:
	self._ipc.poll()
	_ipc.poll()
	if not _ipc.is_open():
		shutdown()

func _on_data(payload: IPCPayload) -> void:
	if (payload.is_error()):
		push_error("IPC: Recieved error code: %d: %s" % [payload.get_error_code(), payload.get_error_messsage()])

	if (payload.op_code == IPCPayload.OpCodes.CLOSE):
		self.shutdown()
		return

	self.emit_signal("raw_data", payload)

	var signal_name = payload.event.to_lower()
	if (payload.command == "DISPATCH" and self.has_signal(signal_name)):
		self.callv("emit_signal", [signal_name] + payload.data.values())

func _to_string() -> String:
	return "[DiscordRPC:%d]" % self.get_instance_id()

func __set(_value) -> void:
	pass

static func is_supported() -> bool:
	return not IPC.get_pipe() == null
