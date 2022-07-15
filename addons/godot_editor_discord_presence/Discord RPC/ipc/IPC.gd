class_name IPC

signal data_recieved(payload)

const PING_INTERVAL_MS: int = 5000 # Send ping every 5s
const PING_TIMOUT_MS: int = 1000 # Wait for 1s for response pong

var _pipe: IPCPipe
var _responses_pool: Array
var _requests_pool: Array

var _io_thread: Thread
var _mutex: Mutex
var _semaphore: Semaphore

func open(path: String) -> int:
	_pipe = get_pipe()
	if _pipe:
		return _pipe.open(path)
	return ERR_CANT_OPEN

func setup() -> bool:
	self._io_thread = Thread.new()
	self._mutex = Mutex.new()
	self._semaphore = Semaphore.new()

	var error: int = self._io_thread.start(self, "_connection_loop", [self._mutex, self._semaphore, self._pipe])
	if (error != OK):
		push_error("Failed to start IO Thread !")
		return false
	return true

func send(request: IPCPayload) -> IPCPayload:
	if (not self.is_open()):
		push_error("IPC: Can not send payloads while not connected to a discord client instance")
		return yield()

	var op_code: int = request.op_code
	var nonce: String = request.nonce

	_mutex.lock()
	self._requests_pool.append(request)
	_mutex.unlock()

	var response: IPCPayload = null

	while (not response):
		var payload: IPCPayload = yield(self, "data_recieved")
		if (op_code == IPCPayload.OpCodes.HANDSHAKE):
			response = payload
		elif (payload.nonce == nonce):
			response = payload
	return response

func post(request: IPCPayload) -> void:
	if (not self.is_open()):
		push_error("IPC: Can not post payloads while not connected to a discord client instance")
		return

	self._pipe.write(request.to_bytes())

func scan() -> IPCPayload:
	if (not self.is_open()):
		push_error("IPC: Can not recieve payloads while not connected to a discord client instance")
		return null

	var data: Array = self._pipe.read()
	var op_code: int = data[0]
	var buffer: PoolByteArray =  data[1]

	var parse_result: JSONParseResult = JSON.parse(buffer.get_string_from_utf8())
	if (parse_result.error != OK):
		push_error("Failed decoding packet of legnth: %d with opcode: %d" % [buffer.size(), op_code])
		return null
	var body: Dictionary = parse_result.result

	var response: IPCPayload = IPCPayload.new()
	response.op_code = op_code
	response.nonce = body["nonce"] if body.get("nonce") else ""
	response.command = body["cmd"] if body.get("cmd") else ""
	response.event = body["evt"] if body.get("evt") else ""
	response.data = body["data"] if body.get("data") is Dictionary else {}
	response.arguments = body["args"] if body.get("args") is Dictionary else {}

	return response

func is_open() -> bool:
	return self._pipe and self._pipe.is_open()

func close() -> void:
	if (self._pipe and self._pipe.is_open()):
		self._pipe.close()
	if (_io_thread and _io_thread.is_active()):
		if self._semaphore:
			self._semaphore.post()
		self._io_thread.wait_to_finish()
	self._pipe = null
	self._io_thread = null
	self._mutex = null
	self._semaphore = null

func poll() -> void:
	if not is_open():
		return
	while _responses_pool.size() > 0:
		_mutex.lock()
		emit_signal("data_recieved", self._responses_pool.pop_back())
		_mutex.unlock()
	if self._semaphore:
		self._semaphore.post()

func _connection_loop(data: Array) -> void:
	var mutex: Mutex = data[0]
	var semaphore: Semaphore = data[1]
	var pipe: IPCPipe = data[2]

	var next_ping: int = OS.get_ticks_msec() + PING_INTERVAL_MS
	var ping_nonce: String
	var sent_ping: bool
	var recieved_pong: bool
	var last_ping: int

	while (pipe.is_open()):
		if (pipe.has_reading()):
			var payload: IPCPayload = self.scan()
			if sent_ping and payload.nonce == ping_nonce:
				recieved_pong = true
				continue
			mutex.lock()
			self._responses_pool.append(payload)
			mutex.unlock()
			if (payload.op_code == IPCPayload.OpCodes.CLOSE):
				break

		elif (self._requests_pool.size() > 0):
			mutex.lock()
			self.post(self._requests_pool.pop_back())
			mutex.unlock()

		# Test to see if connection is still active
		if not sent_ping and OS.get_ticks_msec() >= next_ping:
			# If we havent sent ping and we can send a new ping
			var payload: IPCPayload = IPCPayload.new()
			payload.op_code = IPCPayload.OpCodes.PING
			ping_nonce = payload.nonce
			post(payload)
			sent_ping = true
			last_ping = OS.get_ticks_msec()

		if sent_ping:
			# We sent a ping
			if not recieved_pong and OS.get_ticks_msec() >= last_ping + PING_TIMOUT_MS:
				# Didnt get pong within PING TIMEOUT
				break
			elif recieved_pong:
				# Got a PONG
				sent_ping = false
				recieved_pong = false
				next_ping = OS.get_ticks_msec() + PING_INTERVAL_MS

		if semaphore:
			semaphore.wait()

	close()

static func get_pipe() -> IPCPipe:
	var pipe: IPCPipe
	match OS.get_name():
		"Windows":
			pipe = WindowsPipe.new()
		"Server", "X11", "OSX":
			pipe = UnixPipe.new()

	return pipe

static func get_pipe_path(i: int) -> String:
	var path: String
	match OS.get_name():
		"Windows":
			path = "\\\\?\\pipe\\"
		"Server", "X11", "OSX":
			for env_var in ["XDG_RUNTIME_DIR","TMPDIR","TMP","TEMP"]:
				if (OS.has_environment(env_var)):
					path = OS.get_environment(env_var) + "/"
					break
			if (path.empty()):
				path = "/tmp/"
		_:
			return ""

	return path + "discord-ipc-%d" % i
